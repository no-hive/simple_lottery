// 1. need to check if deploy runs correctly
// 1.1.

// 2. let's check if lottery initialization works
// call createAndStartLottery("test_name", 0) + payable + onlyowner
// should return (lotStarted = true);
// lotNonce == 1;
// lotMaxNonce == 10;
// lotRewards == 0.1 ether;
// contract balance == 0.1 ether;

// let's check if lottery initizalition really should be payable
// call createAndStartLottery("test_name", 0) + onlyowner
// require
// lotNonce == 0;
// lotMaxNonce == 0;
// lotRewards == 0 ether;
// contract balance == 0

// lets check onlyonwer modifier perfomance=
// call createAndStartLottery("test_name", 0) + payable
// should return (lotStarted = true);
// lotNonce == 0;
// lotMaxNonce == 0;
// lotRewards == 0 ether;
// contract balance == 0
