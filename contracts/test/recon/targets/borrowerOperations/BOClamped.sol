// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BORaw} from "./borrowerOperationsRaw/BORaw.sol";
import {IBorrowerOperations} from "src/Interfaces/IBorrowerOperations.sol";
import {Properties} from "./../../Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract BOClamped is BORaw {
    /**
     * Here we clamp the _annualInterestRate
     */
    function clamped_open_trove(
        uint256 _ownerIndex,
        uint256 _collAmount,
        uint256 _boldAmount,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint128 _annualInterestRate,
        uint256 _maxUpfrontFee,
        address _addManager,
        address _removeManager,
        address _receiver
    ) public {
        _annualInterestRate = _fix_interest_rate(_annualInterestRate);
        _collAmount %= collateral.balanceOf(currentUser) + 1;
        uint256 trove = BO_openTrove(
            _ownerIndex,
            _collAmount,
            _boldAmount,
            _upperHint,
            _lowerHint,
            uint256(_annualInterestRate),
            _maxUpfrontFee,
            _addManager,
            _removeManager,
            _receiver
        );
        activeTroves.push(trove);
    }

    function clamped_addCol(uint256 amt) public {
        amt %= collateral.balanceOf(msg.sender) + 1;
        BO_addColl(amt);
        t(false, 'QnD');
    }

    function clamped_adjustTrove(
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _boldChange,
        bool _isDebtIncrease,
        uint256 _maxUpfrontFee
    ) public {
        BO_adjustTrove(_collChange, _isCollIncrease, _boldChange, _isDebtIncrease, _maxUpfrontFee);
    }

    // NOTE caller is owner, but should create option where caller is interestManager
    function clamped_adjustTroveInterestRate(
        uint128 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public {
        _newAnnualInterestRate = _fix_interest_rate(_newAnnualInterestRate);
        BO_adjustTroveInterestRate(uint256(_newAnnualInterestRate), _upperHint, _lowerHint, _maxUpfrontFee);
        // should manage to go through
    }

    //NOTE //msg.sender is batch manager
    function clamped_registerBatchManager(
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint128 _currentInterestRate,
        uint128 _annualManagementFee,
        uint128 _minInterestRateChangePeriod
    ) public {
        _minInterestRate = _fix_interest_rate(_minInterestRate);
        _maxInterestRate = _fix_interest_rate(_maxInterestRate);
        if (_minInterestRate > _maxInterestRate) {
            (_minInterestRate, _maxInterestRate) = (_maxInterestRate, _minInterestRate);
        } // hope this works ..
        _currentInterestRate =
            _currentInterestRate > _maxInterestRate ? _currentInterestRate % _maxInterestRate : _currentInterestRate; //is this ok ?
        _currentInterestRate = _currentInterestRate < _minInterestRate ? _minInterestRate + 1 : _currentInterestRate;

        BO_registerBatchManager(
            _minInterestRate, _maxInterestRate, _currentInterestRate, _annualManagementFee, _minInterestRateChangePeriod
        );
    }

    //NOTE should delegate be an address ?

    function clamped_setInterestIndividualDelegate(
        address _delegate,
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee,
        uint256 _minInterestRateChangePeriod
    ) public {
        _minInterestRate = _fix_interest_rate(_minInterestRate);
        _maxInterestRate = _fix_interest_rate(_maxInterestRate);
        if (_minInterestRate > _maxInterestRate) {
            (_minInterestRate, _maxInterestRate) = (_maxInterestRate, _minInterestRate);
        }

        _newAnnualInterestRate = _newAnnualInterestRate > _maxInterestRate
            ? _newAnnualInterestRate % _maxInterestRate
            : _newAnnualInterestRate; //is this ok ?
        _newAnnualInterestRate =
            _newAnnualInterestRate < _minInterestRate ? _minInterestRate + 1 : _newAnnualInterestRate;
        BO_setInterestIndividualDelegate(
            _delegate,
            _minInterestRate,
            _maxInterestRate,
            _newAnnualInterestRate,
            _upperHint,
            _lowerHint,
            _maxUpfrontFee,
            _minInterestRateChangePeriod
        );
    }

    function clamped_setBatchManagerAnnualInterestRate(
        uint128 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) public { 
        _newAnnualInterestRate = _fix_interest_BM_rate(msg.sender, _newAnnualInterestRate); //NOTE fix clamping
        BO_setBatchManagerAnnualInterestRate(_newAnnualInterestRate, _upperHint, _lowerHint, _maxUpfrontFee);
    }

    // 


    function _fix_interest_rate(uint128 input) internal returns (uint128) {
        if (input > 250 * 1e16) input %= 2.5e18 + 1; //NOTE to better
        if (input < 5e15) input + 5e15;
        return input;
    }

    function _fix_interest_BM_rate(address batchManager, uint128 _newAnnualInterestRate) internal returns (uint128) {
        IBorrowerOperations.InterestBatchManager memory interestBM =
            borrowerOperations.getInterestBatchManager(batchManager);
        if (interestBM.maxInterestRate < _newAnnualInterestRate) _newAnnualInterestRate %= interestBM.maxInterestRate;
        if (interestBM.minInterestRate > _newAnnualInterestRate) _newAnnualInterestRate = interestBM.minInterestRate + 1;
        return _newAnnualInterestRate;
        
    }
}
