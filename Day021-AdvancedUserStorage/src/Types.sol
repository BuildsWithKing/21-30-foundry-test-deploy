//SPDX-License-Identifier: MIT

/// @title Types for AdvancedUserStorage.
/// @author MichealKing (@BuildsWithKing).
/// @notice Created on 13th of Aug, 2025.

pragma solidity ^0.8.30;

abstract contract Types {

// -------------------------------------------- Enums ----------------------------------------
    /// @notice Defines contract's state. 
    enum ContractState {
        
        // 0 => NotActive. 
        NotActive,

        // 1 => Active. 
        Active 
    }

    /// @notice Defines user's gender
    enum Gender {

        // 0 => Default value. 
        Unset, 

        // 1 => Male. 
        Male,

        // 2 => Female. 
        Female
    }

// ------------------------------------------ Struct -------------------------------------------
    /// @notice Groups user's data.
    struct Data {

        // User timestamp. 
        uint256 timestamp;
        
        // User age. 
        uint8 age;

        // User gender. 
        Gender gender;

        // Record User state. 
        bool isRegistered;

         // User full name. 
        string fullName;
        
        // User email. 
        string email;

        // User skill. 
        string skill;
    }
}