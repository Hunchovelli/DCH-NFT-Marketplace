// SPDX-License_Indentifier: MIT
pragma solidity 0.8.19;

// initialise contract as NFT
import { ERC721 } from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
// interface because has I at the beginning
import { IERC721 } from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

// initialise contract as NFT as it creates NFT receipts.
contract DCHMarket is ERC721 { // lets solidity know contract has access to functions of an NFT

    // State variables
    uint256 public sListingFee; // default value at 0
    uint256 public sReceiptCounter; // default value at 0

    // Struct 
    // struct for the receipts
    struct Receipt {
        address owner;
        address nft;
        uint256 tokenId;
        uint256 excess;
        bool redeemed;
    }

    // Mappings
    mapping(uint256 => Receipt) public sReceipt;

    // Errors
    error InsufficientListingFee(uint256 amountSent, uint256 listingFee);
    error DepositNotOwner(address depositor, address nft, uint256 tokenId);
    error DepositorMustApproveMarket(address nft, uint256 tokenId);

    // Event 
    event Deposit(address depositor, address nft, uint256 tokenId);

    // Constructor
    constructor(uint256 listingFee) ERC721("DCHMarket", "DCM") { // naming of the nft as a string and a symbol respectively from the abstract constructor of ERC71.sol as we are inheriting from it
        sListingFee = listingFee;
    }

    // External Functions - Payable First

    function deposit (
        address _nft,
        uint256 _tokenId
    ) external payable {
        IERC721 nft = IERC721(_nft);

        // Checks
        if (msg.value < s_listingFee) revert InsufficientListingFee(msg.value, s_listingFee);
        if (nft.ownerOf(_tokenId) != msg.sender) revert DepositNotOwner(msg.sender, _nft, _tokenId);
        if (nft.getApproved(_tokenId) != address(this)) revert DepositorMustApproveMarket(_nft, _tokenId);

        // Effects - state changing actions
        uint256 excess = msg.value - s_listingFee; // calculates by how much the user has paid. msg.value is global variable of how much user has paid
        // requires an approval which is why we used the _getApproved function above
        nft.transferFrom(msg.sender, address(this), _tokenId);

        // Create new receipt for user
        Receipt memory receipt = Receipt ({
            owner: msg.sender,
            nft: _nft,
            tokenId: _tokenId,
            excess: excess,
            reddemed: false
        });
        // increment counter so we can keep track of what nft we are on
        s_receiptCounter++;

        // Interactions - external calls and any calls to the user. changes that happen in external contracts

        _mint(msg.sender, s_receiptCounter); // creates a new NFT of the receipt to the caller of the contract

        emit Deposit(msg.sender, _nft, _tokenId); // release an event onto the blockchain
        

    }

    // External Functions - Nonpayable

    // Public Functions - Payable First

    // Public Functions - Nonpayable

    // Internal / Private Functions

    // View Functions
}
