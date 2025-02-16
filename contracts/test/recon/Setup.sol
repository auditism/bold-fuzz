// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {AddressesRegistry} from "src/AddressesRegistry.sol";
import {ActivePool} from "src/ActivePool.sol";
import {BaseSetup} from "@chimera/BaseSetup.sol";
import {BoldToken} from "src/BoldToken.sol";
import {BorrowerOperations} from "src/BorrowerOperations.sol";
import {CollateralRegistry} from "src/CollateralRegistry.sol";
import {CollSurplusPool} from "src/CollSurplusPool.sol";
import {console} from "forge-std/console.sol";

import {DefaultPool} from "src/DefaultPool.sol";
import {ERC20Token} from "./mocks/ERC20.sol";
import {GasPool} from "src/GasPool.sol";

import {FixedAssetReader} from "src/NFTMetadata/utils/FixedAssets.sol";
import {IAddressesRegistry} from "src/Interfaces/IAddressesRegistry.sol";
import {IERC20Metadata} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IInterestRouter} from "src/Interfaces/IInterestRouter.sol";
import {ITroveManager} from "src/Interfaces/ITroveManager.sol";

import {IWETH} from "src/Interfaces/IWETH.sol";
import {HintHelpers} from "src/HintHelpers.sol";
import {MetadataNFT} from "src/NFTMetadata/MetadataNFT.sol";
import {MockPriceFeed} from "./mocks/MockPriceFeed.sol";
import {MultiTroveGetter} from "src/MultiTroveGetter.sol";
import {PredeployCalculator} from "./PredeployCalculator.sol";
import {TroveManager} from "src/TroveManager.sol";
import {TroveNFT} from "src/TroveNFT.sol";
import {StabilityPool} from "src/StabilityPool.sol";
import {SortedTroves} from "src/SortedTroves.sol";

import {Asserts} from "@chimera/Asserts.sol";
import {Weth} from "./mocks/WETH.sol";

abstract contract Setup is BaseSetup, PredeployCalculator {
    AddressesRegistry addressesRegistry;
    ActivePool activePool;

    BoldToken boldToken;
    BorrowerOperations borrowerOperations;
    CollSurplusPool collSurplusPool;
    CollateralRegistry collateralRegistry;
    DefaultPool defaultPool;
    GasPool gasPool;
    IInterestRouter interestRouter;

    FixedAssetReader fixedAssetReader;
    HintHelpers hintHelpers;
    MetadataNFT metadataNFT;
    MockPriceFeed priceFeed;
    MultiTroveGetter multiTroveGetter;

    TroveManager troveManager;
    TroveNFT troveNFT;
    StabilityPool stabilityPool;
    SortedTroves sortedTroves;
    ERC20Token collateral;
    Weth weth;

    address[] precomputed;
    address[] users;
    uint256[] activeTroves;

    // USERS
    address owner = address(this);
    address bob = address(123);
    address patrick = address(234);
    address schneider = address(345);

    address currentUser;
    uint256 currentTrove;

    ///

    // address currentActor;
    uint256 randomUnit; //NOTE FOR SWITCH

    function setup() internal virtual override {
        //HELPER
        bytes4[] memory fixedAsset;
        FixedAssetReader.Asset[] memory assets;

        addressesRegistry = new AddressesRegistry(owner, 1.5e18, 1.5e18, 1.5e18, 1e17, 1.5e17); //consider programmatic deployment, yes and do not forget the dictionary
        collateral = new ERC20Token(); // N 2
        weth = new Weth();
        precomputed = setupPrecomputedAddresses(address(this));

        users.push(owner);
        users.push(bob);

        IAddressesRegistry.AddressVars memory vars = IAddressesRegistry.AddressVars({
            activePool: ActivePool(precomputed[0]),
            boldToken: BoldToken(precomputed[1]),
            borrowerOperations: BorrowerOperations(precomputed[2]),
            collSurplusPool: CollSurplusPool(precomputed[3]),
            collateralRegistry: CollateralRegistry(precomputed[4]), // Not in deployment list
            collToken: ERC20Token(collateral),
            defaultPool: DefaultPool(precomputed[5]),
            gasPoolAddress: precomputed[7],
            hintHelpers: HintHelpers(precomputed[8]),
            interestRouter: IInterestRouter(address(666)),
            metadataNFT: MetadataNFT(precomputed[9]),
            multiTroveGetter: MultiTroveGetter(precomputed[10]),
            priceFeed: MockPriceFeed(precomputed[11]),
            sortedTroves: SortedTroves(precomputed[12]),
            stabilityPool: StabilityPool(precomputed[13]),
            troveManager: TroveManager(precomputed[14]),
            troveNFT: TroveNFT(precomputed[15]),
            WETH: IWETH(weth)
        });
        addressesRegistry.setAddresses(vars); // nonce 3

        ITroveManager[] memory troveManagers = new ITroveManager[](1);
        IERC20Metadata[] memory erc20Tokens = new IERC20Metadata[](1);
        ////////////////

        troveManagers[0] = TroveManager(precomputed[14]);
        erc20Tokens[0] = IWETH(weth);

        // do i need to separate stuff ?
        activePool = new ActivePool(addressesRegistry);
        boldToken = new BoldToken(owner);
        borrowerOperations = new BorrowerOperations(addressesRegistry);
        collSurplusPool = new CollSurplusPool(addressesRegistry);
        collateralRegistry = new CollateralRegistry(boldToken, erc20Tokens, troveManagers);
        defaultPool = new DefaultPool(addressesRegistry);
        fixedAssetReader = new FixedAssetReader(address(1), fixedAsset, assets);
        gasPool = new GasPool(addressesRegistry);
        hintHelpers = new HintHelpers(collateralRegistry);
        interestRouter = IInterestRouter(address(666));
        metadataNFT = new MetadataNFT(fixedAssetReader);
        multiTroveGetter = new MultiTroveGetter(collateralRegistry);
        priceFeed = new MockPriceFeed(1e18);
        sortedTroves = new SortedTroves(addressesRegistry);
        stabilityPool = new StabilityPool(addressesRegistry);
        troveManager = new TroveManager(addressesRegistry);
        troveNFT = new TroveNFT(addressesRegistry);

        boldToken.setBranchAddresses(address(troveManager), address(stabilityPool), address(borrowerOperations), address(activePool));


        
    }
}
