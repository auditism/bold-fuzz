// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {IBorrowerOperations} from "src/Interfaces/IBorrowerOperations.sol";
import {Properties} from "./../../Properties.sol";

abstract contract BOHelpers is Properties {
    function _fix_max_min_interest(
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        uint128 _newAnnualInterestRate,
        uint128 _minInterestRateChangePeriod
    ) internal returns (uint128, uint128, uint128) {
        if (_minInterestRate > _maxInterestRate) {
            (_minInterestRate, _maxInterestRate) = (_maxInterestRate, _minInterestRate);
        }

        _newAnnualInterestRate = _newAnnualInterestRate > _maxInterestRate
            ? _newAnnualInterestRate % _maxInterestRate
            : _newAnnualInterestRate;
        _newAnnualInterestRate =
            _newAnnualInterestRate < _minInterestRate ? _minInterestRate + 1 : _newAnnualInterestRate;
        if (_minInterestRateChangePeriod < 1 hours) _minInterestRateChangePeriod += 1 hours;
        return (_minInterestRate, _maxInterestRate, _minInterestRateChangePeriod);
    }

    function _fix_interest_rate(uint128 input) internal returns (uint128) {
        if (input > 250 * 1e16) input %= 2.5e18 + 1; //NOTE to better
        if (input < 5e15) input + 5e15;
        return input;
    }

    function _fix_interest_BM_rate(address batchManager, uint128 _newAnnualInterestRate) internal returns (uint128) {
        IBorrowerOperations.InterestBatchManager memory interestBM =
            borrowerOperations.getInterestBatchManager(batchManager);
        if (interestBM.maxInterestRate < _newAnnualInterestRate) _newAnnualInterestRate %= interestBM.maxInterestRate;
        if (interestBM.minInterestRate > _newAnnualInterestRate) {
            _newAnnualInterestRate = interestBM.minInterestRate + 1;
        }
        return _newAnnualInterestRate;
    }
}
