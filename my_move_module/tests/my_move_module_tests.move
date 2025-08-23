
#[test_only]
module my_move_module::my_move_module_tests;
use my_move_module::my_move_module;

use sui::test_scenario::{Scenario, begin, end};

const ENotImplemented: u64 = 0;

#[test]
fun test_my_move_module() {
    let mut test = begin(@0xF);
    
    //your test code goes here
    
    end(test);
}

#[test, expected_failure(abort_code = ::my_move_module::my_move_module_tests::ENotImplemented)]
fun test_my_move_module_fail() {
    abort ENotImplemented
}

