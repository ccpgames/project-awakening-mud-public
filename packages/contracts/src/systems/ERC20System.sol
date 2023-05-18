// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { ERC20TokenTable } from "../codegen/Tables.sol";
import { AllowanceTable } from "../codegen/Tables.sol";
import {IERC20MUD } from "../proxy/interfaces/IERC20MUD.sol"; 

address constant SingletonKey = address(uint160(0x060D));


contract ERC20System is System {
    /**
     * @dev Sets the values for {name} and {symbol} and {proxy}.
     * These values are immutable: they can only be set once (ideally during postDeploy script) 
     */
    function initializeERC20(uint256 tokenId, address _proxy, string calldata _name, string calldata _symbol) public {
      require(ERC20TokenTable.lengthName(tokenId, SingletonKey) == 0, "ERC20: Metadata already initialized");
      ERC20TokenTable.setProxy(tokenId, SingletonKey, _proxy);
      ERC20TokenTable.setName(tokenId, SingletonKey, _name);
      ERC20TokenTable.setSymbol(tokenId, SingletonKey, _symbol);
    }

    function nameERC20(uint256 tokenId) public view returns (string memory) {
        return ERC20TokenTable.getName(tokenId, SingletonKey);
    }

    function symbolERC20(uint256 tokenId) public view returns (string memory) {
        return ERC20TokenTable.getSymbol(tokenId, SingletonKey);
    }
  
    function totalSupplyERC20(uint256 tokenId) public view  returns (uint256) {
        return ERC20TokenTable.getTotalSupply(tokenId, SingletonKey);
    }

    function balanceOfERC20(uint256 tokenId, address account) public view  returns (uint256) {
        return ERC20TokenTable.getBalance(tokenId, account);
    }

    function transferERC20(uint256 tokenId, address to, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _transfer(tokenId, owner, to, amount);
        return true;
    }

    function allowanceERC20(uint256 tokenId, address owner, address spender) public view returns (uint256) {
        return AllowanceTable.get(tokenId, owner, spender);
    }
    
    function approveERC20(uint256 tokenId, address spender, uint256 amount) public {
        address owner = _msgSender();
        _approve(tokenId, owner, spender, amount);
    }

    function transferFromERC20(uint256 tokenId, address from, address to, uint256 amount) public {
        address spender = _msgSender();
        _spendAllowance(tokenId, from, spender, amount);
        _transfer(tokenId, from, to, amount);
    }
    
    function increaseAllowanceERC20(uint256 tokenId, address spender, uint256 addedValue) public virtual {
        address owner = _msgSender();
        _approve(tokenId, owner, spender, allowanceERC20(tokenId, owner, spender) + addedValue);
    }

    function decreaseAllowanceERC20(uint256 tokenId, address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowanceERC20(tokenId, owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(tokenId, owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function transferERC20(uint256 tokenId, address from, address to, uint256 amount) public {
      address proxy = ERC20TokenTable.getProxy(tokenId, SingletonKey);
      require(_msgSender() == proxy, "ERC20System: not authorized to transfer");
      _transfer(tokenId, from, to, amount);
    }

    function _transfer(uint256 tokenId, address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = ERC20TokenTable.getBalance(tokenId, from);
        uint256 toBalance = ERC20TokenTable.getBalance(tokenId, to);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            ERC20TokenTable.setBalance(tokenId, from, fromBalance - amount);
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.

            ERC20TokenTable.setBalance(tokenId, to, toBalance + amount);
        }

        // emit transfer
        _emitTransfer(tokenId, from, to, amount);
    }

    
    function mint(uint256 tokenId, address account, uint256 amount) public {
      address proxy =ERC20TokenTable.getProxy(tokenId, SingletonKey);
      require(_msgSender() == proxy, "ERC20System: not authorized to mint");
      _mint(tokenId, account, amount);
    }

    function _mint(uint256 tokenId, address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        uint256 _totalSupply = ERC20TokenTable.getTotalSupply(tokenId, SingletonKey);
        uint256 balance = ERC20TokenTable.getBalance(tokenId, account);
        ERC20TokenTable.setTotalSupply(tokenId, SingletonKey, _totalSupply + amount);

        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            ERC20TokenTable.setBalance(tokenId, account, balance + amount);
        }

        // emit transfer
        _emitTransfer(tokenId, address(0), account, amount);

    }

    function burn(uint256 tokenId, address account, uint256 amount) public {
      address proxy =ERC20TokenTable.getProxy(tokenId, SingletonKey);
      require(_msgSender() == proxy, "ERC20System: not authorized to burn");
      _burn(tokenId, account, amount);
    } 

    function _burn(uint256 tokenId, address account, uint256 amount) private {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = ERC20TokenTable.getBalance(tokenId, account);

        uint256 _totalSupply = ERC20TokenTable.getTotalSupply(tokenId, SingletonKey);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        unchecked {
            ERC20TokenTable.setBalance(tokenId, account, accountBalance - amount);
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            ERC20TokenTable.setTotalSupply(tokenId, SingletonKey, _totalSupply - amount);
        }

        // emit transfer
        _emitTransfer(tokenId, account, address(0), amount);
    }
    

    function approve(uint256 tokenId, address owner, address spender, uint256 amount) public {
      address proxy = ERC20TokenTable.getProxy(tokenId, SingletonKey);
      require(_msgSender() == proxy, "ERC20System: not authorized to approve");
      _approve(tokenId, owner, spender, amount);
    }

    function _approve(uint256 tokenId, address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        AllowanceTable.set(tokenId, owner, spender, amount);
    }

    function spendAllowance(uint256 tokenId, address owner, address spender, uint256 amount) public {
      address proxy = ERC20TokenTable.getProxy(tokenId, SingletonKey);
      require(_msgSender() == proxy, "ERC20System: not authorized to spend allowance");
      _spendAllowance(tokenId, owner, spender, amount);
    }

    function _spendAllowance(uint256 tokenId, address owner, address spender, uint256 amount) private {
        uint256 currentAllowance = allowanceERC20(tokenId, owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(tokenId, owner, spender, currentAllowance - amount);
            }
        }

        // emit approval
        _emitApproval(tokenId, owner, spender, amount);
    }

    function _emitApproval(uint256 tokenId, address owner, address spender, uint256 value) private {
      IERC20MUD proxy = IERC20MUD(ERC20TokenTable.getProxy(tokenId, SingletonKey));
      proxy.emitApproval(owner, spender, value);
    }

    function _emitTransfer(uint256 tokenId, address from, address to, uint256 value) private {
      IERC20MUD proxy = IERC20MUD(ERC20TokenTable.getProxy(tokenId, SingletonKey));
      proxy.emitApproval(from, to, value);
    }
}