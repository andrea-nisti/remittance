const RemittanceDerived = artifacts.require("./RemittanceDerived.sol");


//**********************INCOMPLETE, Under Construction****************+

contract('Remittance test', accounts => {

    console.log(accounts);
    // Will show ["0x1c25cc6a9f326ac277ce6879b03c4fd0596e10eb", "0x991b2246c8ed92a63ae64c9b910902f55350cd13", "0x258a69adcfb68ad70182bb351c7fa0b0e4b4b4cd"]
    // unit tests come here
    let instance;

    beforeEach(async function() {
        instance = await RemittanceDerived.new({ from: accounts[0] });
    });


    it("should check the correct chain of events", function() {
        console.log(instance.address);
        let puzzle;
        let amount = 5;
        return instance.giveMyHash.call("cane","gatto");
        .then(res => 
            {
                puzzle = res;
                return instance.deposit(puzzle, accounts[2],{ from: accounts[0], value: web3.toWei(amount,"ether")});
            });

    });
        
});
        
