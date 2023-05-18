// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

interface IERC20System {
  function initializeERC20(uint256 tokenId, address _proxy, string calldata _name, string calldata _symbol) external;

  function nameERC20(uint256 tokenId) external view returns (string memory);

  function symbolERC20(uint256 tokenId) external view returns (string memory);

  function totalSupplyERC20(uint256 tokenId) external view returns (uint256);

  function balanceOfERC20(uint256 tokenId, address account) external view returns (uint256);

  function transferERC20(uint256 tokenId, address to, uint256 amount) external returns (bool);

  function allowanceERC20(uint256 tokenId, address owner, address spender) external view returns (uint256);

  function approveERC20(uint256 tokenId, address spender, uint256 amount) external;

  function transferFromERC20(uint256 tokenId, address from, address to, uint256 amount) external;

  function increaseAllowanceERC20(uint256 tokenId, address spender, uint256 addedValue) external;

  function decreaseAllowanceERC20(uint256 tokenId, address spender, uint256 subtractedValue) external returns (bool);

  function transferERC20(uint256 tokenId, address from, address to, uint256 amount) external;

  function mint(uint256 tokenId, address account, uint256 amount) external;

  function burn(uint256 tokenId, address account, uint256 amount) external;

  function approve(uint256 tokenId, address owner, address spender, uint256 amount) external;

  function spendAllowance(uint256 tokenId, address owner, address spender, uint256 amount) external;
}
