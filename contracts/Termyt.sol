// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

// =======================================================================================================
// Line 10 and 11, imports two openzepplin contracts which are trusted, reliable and well-audited.
// The ERC721 contract is a standard contract for minting ERC721 Tokens which follow the EIP721 standards.
// The Ownable contract is a standard contract for utilizing access control on your own smart contract.
// =======================================================================================================
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// ===========================================================================================================================
// Initializing my smart contract [NFTs] which inherits two props [ERC721Enumerable and Ownable] from the above contracts.
// ===========================================================================================================================
contract Termyt is ERC721Enumerable, Ownable {
  using Strings for uint256;

// ==========================================================
// Initializing my State Variables with thier default values.
// ========================================================== 
  string baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 1 ether;
  uint256 public maxSupply = 5000;
  uint256 public maxPreSaleMintSupply = 1500;
  uint256 public maxPublicMintSupply = 3500;
  uint256 public maxMintAmount = 5;
  bool public preSaleMintState = false;
  bool public publicMintState = false;
  bool public paused = false;

  event Minted(address indexed owner, uint256 indexed amount);

// ==========================================================================================================
// Initializng my constructor function which is called once the contract is deployed. It takes some arguments 
// which must be given to the constructor function as parameters on the deployment of the contract.
// ==========================================================================================================
  constructor(
    string memory _name,
    string memory _symbol,
    string memory initBaseURI
  ) ERC721(_name, _symbol) {
    require(maxPreSaleMintSupply + maxPublicMintSupply == maxSupply, "Please adjust Supply parameters");
    setBaseURI(initBaseURI);
    setPreSaleMintState(true);
  }

// ===============================================================================
// Internal Function which is only called from this contract or derived contracts.
// ===============================================================================

 // ===========================================================
 // The _baseURI function sets the baseURI of all NFTs.
 // The baseURI is always prefixed to the tokenURI of all NFTs. 
 // ===========================================================
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

// ===========================================================================
// Public Functions which can be called by any external contracts or accounts.
// ===========================================================================

 // =====================================================
 // Mint function which mints a specified amount of NFTs.
 // =====================================================
  function mint(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(preSaleMintState || publicMintState, "Neither PreSale or Public Mint has started.");
    require(_mintAmount <= maxMintAmount);

    if (msg.sender != owner()) {
      require(msg.value >= cost * _mintAmount);
    }

    if(preSaleMintState) {
        require(supply + _mintAmount <= maxPreSaleMintSupply, "PreSale Mint is Over.");

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }

        emit Minted(msg.sender, _mintAmount);
    } else if(publicMintState) {
        require(supply + _mintAmount <= maxPublicMintSupply, "Public Mint is Over.");

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);

            emit Minted(msg.sender, _mintAmount);
        }
    }
  }

 // ==========================================================================
 // The walletOfOwner functions gets all the tokens in the wallet of the owner
 // and also retrieves the tokenIDs of the tokens in the owner's wallet.
 // ==========================================================================
  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  // ===============================================================================
  // The tokenURI function returns a URI of a given tokenID from the owner's wallet. 
  // It prefixes the baseURI set by the owner to the tokenID and baseExtension.
  // ===============================================================================
  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId, baseExtension))
        : "";
  }

// ========================================================================================================
// OnlyOwner Functions which leverages the onlyOwner modifier of the Ownable.sol contract from OpenZepplin.
// This asserts that only the owner/deployer of this smart contract can call these functions.
// ========================================================================================================
  
  // ==============================================
  // The setCost function sets the cost of the NFT.
  // ==============================================
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  // ================================================================================
  // The setmaxMintAmount function set the maximum amount of NFTs that can be minted. 
  // ================================================================================
  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  // =========================================================================================
  // The setBaseURI set the baseURI of all NFTs which is prepended to the tokenURI or tokenID.
  // =========================================================================================
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  // =========================================================================================================
  // The setBaseExtension sets the base Extension of all NFTs which iss postpended to the tokenURI or tokenID.
  // =========================================================================================================
  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  // =========================================================================
  // The setPreSaleMintState sets the PreSaleMintState to either TRUE OR FALSE
  // =========================================================================
  function setPreSaleMintState(bool _state) public onlyOwner {
    preSaleMintState = _state;
  }

  // =========================================================================
  // The setPublicMintState sets the publicMintState to either TRUE OR FALSE
  // =========================================================================
  function setPublicMintState(bool _state) public onlyOwner {
    publicMintState = _state;
  }
  
  // =================================================================================
  // The pause functions applies a pause on the minting of NFTs by the smart contract. 
  // =================================================================================
  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
  
  // ========================================================
  // This will payout the owner 100% of the contract balance.
  // ========================================================
  function withdraw() public payable onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
}