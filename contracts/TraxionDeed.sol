pragma solidity ^0.4.21;

import "../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

/**
* @title TraxionDeed 
* @dev Traxion Pre ICO deed of sale
*
*/

contract TraxionDeed is ERC721Token, Pausable {

    using SafeMath for uint256;

    string public constant _name = "Traxion Deed of Sale";
    string public constant _symbol = "TXND";
    uint256 public constant rate = 1000;
    uint256 public weiRaised;
    uint256 public iouTokens;

    /** @dev Modified Pausable.sol from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol 
        Purpose of this is to prevent unecessary burning of deed of sale during pre-ICO stage.
    ***/

    event MainICO();
    
    bool public main_sale = false;

   /**
   * @dev Modifier to make a function callable only when during Pre-ICO.
   */
    modifier isPreICO() {
        require(!main_sale);
        _;
    }    
    
   /**
   * @dev Modifier to make a function callable only when during Main-ICO.
   */
    modifier isMainICO() {
        require(main_sale);
        _;
    }

   /**
   * @dev called by the owner to initialize Main-ICO
   */
    function mainICO() public onlyOwner isPreICO {
        main_sale = true;
        emit MainICO();
    }

    /*** @dev Traxion Deed of Sale Metadata ***/
    struct Token {
        address mintedFor;
        uint64 mintedAt;
        uint256 tokenAmount;
        uint256 weiAmount;
    }

    Token[] public tokens;

    /*** @dev function to create Deed of Sale ***/

    function buyTokens(address beneficiary, uint256 weiAmt) public onlyOwner whenNotPaused {
        require(beneficiary != address(0));
        require(weiAmt != 0);

        uint256 _tokenamount = weiAmt.mul(rate);

        mint(beneficiary, _tokenamount, weiAmt);
    }

    /*** @dev function to burn the deed and swap it to Traxion Tokens ***/

    function burn(uint256 _tokenId) public isMainICO {
        super._burn(ownerOf(_tokenId), _tokenId);
    }

    function mint(address _to, uint256 value, uint256 weiAmt) internal returns (uint256 _tokenId) {

        weiRaised = weiRaised.add(weiAmt);
        iouTokens = iouTokens.add(value);

        _tokenId = tokens.push(Token({
                        mintedFor: _to,
                        mintedAt: uint64(now),
                        tokenAmount: value,
                        weiAmount: weiAmt
                    })) - 1;
                    
        super._mint(_to, _tokenId);
    }

}
