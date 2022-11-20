// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./WETH.sol";
import "./SafeMath.sol";

contract DepositContract {
    using SafeMath for uint256;

    address payable public immutable _weth; // 替换为自己部署的 WETH 地址
    uint256 public constant rewardBase = 5; // 每5个币经过一个区块，可以领取1个ETH奖励。注意这里的奖励是ETH而不是WETH；
    uint256 public immutable startBlock; // 在构造函数中定义
    uint256 public immutable endBlock; // 在构造函数中定义
    mapping(address => uint256) public depositAmount; // 用户的存款总量
    mapping(address => uint256) public checkPoint; // 每次存款或提取本金时，更新这个值
    mapping(address => uint256) public calculatedReward; // 已经计算的利息
    mapping(address => uint256) public claimedReward; // 已经提取的利息

    event Deposit(address indexed sender, uint256 amount);
    event Claim(address indexed sender, address recipient, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);

    constructor(address payable _wethAddress, uint256 _period) {
        // period 为从当前开始，延续多少个区块
        startBlock = block.number;
        endBlock = block.number + _period + 1;
        _weth = _wethAddress;
    }
    
    // 修饰符，充值时只允许在设定的区块范围内
    modifier onlyValidTime() {
        require(block.number < endBlock, "too early");
        require(block.number > startBlock, "too late");
        _;
    }

    // 存钱到合约
    function deposit(uint256 _amount) public onlyValidTime returns (bool) {
        require (_amount > 0);
        require (_amount <= type(uint256).max);
        WETH weth = WETH(_weth);
        weth.transferFrom(msg.sender, payable(address(this)), _amount);
        uint256 _checkPoint = depositAmount[msg.sender].mul(block.number).sub(checkPoint[msg.sender]);
        depositAmount[msg.sender] = depositAmount[msg.sender].add(_amount);
        checkPoint[msg.sender] = depositAmount[msg.sender].mul(block.number);
        calculatedReward[msg.sender] = calculatedReward[msg.sender].add(_checkPoint.div(rewardBase)); 
        emit Deposit(msg.sender, _amount);
        return true;
    }

    // 查询利息
    function getPendingReward(address _account)
        public
        view
        returns (uint256 pendingReward)
    {
        // 此处编写业务逻辑
        require (_account != address(0), "address can not be zero!");
        if (block.number >= endBlock) {
            pendingReward = calculatedReward[_account].add((depositAmount[_account].mul(endBlock.sub(1)).sub(checkPoint[_account])).div(rewardBase)).sub(claimedReward[_account]);
        }
        pendingReward = calculatedReward[_account].add((depositAmount[_account].mul(block.number).sub(checkPoint[_account])).div(rewardBase)).sub(claimedReward[_account]);
        
    }

    // 领取利息
    function claimReward(address payable _toAddress) public returns (bool) {
        // 此处编写业务逻辑
        require(_toAddress != address(0));
        uint256 pendingReward = getPendingReward(msg.sender);
        claimedReward[msg.sender] =claimedReward[msg.sender].add(pendingReward);
        emit Claim(msg.sender, _toAddress, pendingReward);
        return true;
    }

    // 提取一定数量的本金
    function withdraw(uint256 _amount) public returns (bool) {
        //此处编写业务逻辑
        require(_amount > 0);
        require(_amount <= depositAmount[msg.sender]);
        WETH weth = WETH(_weth);
        if (block.number >= endBlock) {
            claimReward(msg.sender);
            weth.withdrawTo(msg.sender, _amount);
            calculatedReward[msg.sender] = calculatedReward[msg.sender].add((depositAmount[msg.sender].mul(endBlock.sub(1)).sub(checkPoint[msg.sender])).div(rewardBase));
            depositAmount[msg.sender] = depositAmount[msg.sender].sub(_amount);
            checkPoint[msg.sender] = depositAmount[msg.sender].mul(block.number);
            emit Withdraw(msg.sender, _amount);
            return true;
        }
        
        claimReward(msg.sender);
        weth.withdrawTo(msg.sender, _amount);
        calculatedReward[msg.sender] = calculatedReward[msg.sender].add((depositAmount[msg.sender].mul(block.number).sub(checkPoint[msg.sender])).div(rewardBase));
        depositAmount[msg.sender] = depositAmount[msg.sender].sub(_amount);
        checkPoint[msg.sender] = depositAmount[msg.sender].mul(block.number);
        emit Withdraw(msg.sender, _amount);
        return true;
    }
  

    // 以下不用改
    // 用于在Remix本地环境中增加区块高度
    uint256 counter;

    function addBlockNumber() public {
        counter++;
    }

    // 获取当前区块高度
    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }
}
