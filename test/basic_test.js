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

        let puzzle;
        let amount = 5;

        return instance.giveMyHash.call("cane","gatto",accounts[2])
        .then(res => 
            {
                puzzle = res;
                console.log("Creating a new deposit");
                return instance.deposit(puzzle, 3600,{ from: accounts[0], value: web3.toWei(amount,"ether")});
            })
        .then(txObj =>
            {
                assert.equal(txObj.logs.length,1);
                assert.equal(txObj.logs[0].args.amount, web3.toWei(amount,"ether"));
                assert.equal(txObj.logs[0].args.puzzle, puzzle);
                console.log("Taking money..");
                return instance.giveMeMoney("cane","gatto",{ from: accounts[2]});
            })
        .then(txObj =>
            {
                assert.equal(txObj.logs.length,1);
                assert.equal(txObj.logs[0].args.amount, web3.toWei(amount,"ether"));
            })


    });

    it("should check the wrong chain of events",async function() {
    
        let amount = 5;   
        let puzzle = await instance.giveMyHash.call("cane","gatto",accounts[2]);
        let tx     = await instance.deposit(puzzle,3600 ,{ from: accounts[0], value: web3.toWei(amount,"ether")});
       
        assert.equal(tx.logs.length,1);
        assert.equal(tx.logs[0].args.amount, web3.toWei(amount,"ether"));
        assert.equal(tx.logs[0].args.puzzle, puzzle);
       
        try{
            await instance.giveMeMoney("cane","gato",{ from: accounts[2]});
        }catch(err){
            console.log("You got: " + err);
            assert("You got: " + err);
            return;
        }
        //It doesn't  print the assert message..
        console.log("You didn't catch the error");
        assert.fail("You didn't catch the error");
        
    });

    it("should check the safety of the giveMeMoney() function, only the exchanger can use it",async function() {
    
        let amount = 5;   
        let puzzle = await instance.giveMyHash.call("cane","gatto", accounts[2]);
        let tx     = await instance.deposit(puzzle,3600 ,{ from: accounts[0], value: web3.toWei(amount,"ether")});
       
        assert.equal(tx.logs.length,1);
        assert.equal(tx.logs[0].args.amount, web3.toWei(amount,"ether"));
        assert.equal(tx.logs[0].args.puzzle, puzzle);
       
        try{
            await instance.giveMeMoney("cane","gatto",{ from: accounts[1]});
        }catch(err){
            console.log("You got: " + err);
            assert("You got: " + err);
            return;
        }
        //It doesn't  print the assert message..
        console.log("You didn't catch the error");
        assert.fail("You didn't catch the error");
        
    });

    it("should check the one-time usage of a puzzle",async function() {
    
        let amount = 5;   
        let puzzle = await instance.giveMyHash.call("cane","gatto",accounts[2]);
        let tx     = await instance.deposit(puzzle,3600,{ from: accounts[0], value: web3.toWei(amount,"ether")});
       
        assert.equal(tx.logs.length,1);
        assert.equal(tx.logs[0].args.amount, web3.toWei(amount,"ether"));
        assert.equal(tx.logs[0].args.puzzle, puzzle);
       
        //Perform a second deposit with the same puzzle and expect a throw. Change the amount just to have "different" deposits
        try{
            await instance.deposit(puzzle,3600,{ from: accounts[0], value: web3.toWei(amount + 3,"ether")});
        }catch(err){
            console.log("You got: " + err);
            assert("You got: " + err);
            return;
        }
        //It doesn't  print the assert message..
        console.log("You didn't catch the error");
        assert.fail("You didn't catch the error");
        
    });
    it("should check the soft switches",async function() {
    
        let amount = 5;   
        let puzzle = await instance.giveMyHash.call("cane","gatto",accounts[2]);
        let tx     = await instance.deposit(puzzle,3600,{ from: accounts[0], value: web3.toWei(amount,"ether")});
       
        //Here we check running == true
        assert.equal(tx.logs.length,1);
        assert.equal(tx.logs[0].args.amount, web3.toWei(amount,"ether"));
        assert.equal(tx.logs[0].args.puzzle, puzzle);
        
        //Perform a deposit and expect a throw
        await instance.stopSwitch({from: accounts[0]});
        try{
            await instance.deposit(puzzle,3600,{ from: accounts[0], value: web3.toWei(amount,"ether")});
        }catch(err){
            console.log("You got: " + err);
            assert("You got: " + err);
            return;
        }
        //It doesn't  print the assert message..
        console.log("You didn't catch the error");
        assert.fail("You didn't catch the error");
        
    });
        
});