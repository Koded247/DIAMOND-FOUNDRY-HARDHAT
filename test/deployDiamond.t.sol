// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/Diamond.sol";
import "./helpers/DiamondUtils.sol";

contract DiamondDeployer is DiamondUtils, IDiamondCut {
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;

    function testDeployDiamond() public {
      
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();

       
        FacetCut[] memory cut = new FacetCut[](2);

        // DiamondLoupeFacet selectors
        bytes4[] memory loupeSelectors = new bytes4[](5);
        loupeSelectors[0] = bytes4(keccak256("facetAddress(bytes4)"));       
        loupeSelectors[1] = bytes4(keccak256("facetAddresses()"));           
        loupeSelectors[2] = bytes4(keccak256("facetFunctionSelectors(address)")); 
        loupeSelectors[3] = bytes4(keccak256("facets()"));                    
        loupeSelectors[4] = bytes4(keccak256("supportsInterface(bytes4)"));   

        cut[0] = FacetCut({
            facetAddress: address(dLoupe),
            action: FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        // OwnershipFacet selectors
        bytes4[] memory ownershipSelectors = new bytes4[](2);
        ownershipSelectors[0] = bytes4(keccak256("owner()"));                   
        ownershipSelectors[1] = bytes4(keccak256("transferOwnership(address)")); 

        cut[1] = FacetCut({
            facetAddress: address(ownerF),
            action: FacetCutAction.Add,
            functionSelectors: ownershipSelectors
        });

      
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        // Call a function to verify
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}