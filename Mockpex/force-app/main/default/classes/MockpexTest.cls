@IsTest
public with sharing class MockpexTest {

    /**
     * Can return values.
     */
    @isTest
    public static void SimpllyMethodNameMock_Test() {
        Mockpex setting = new Mockpex();

        setting.when('fizzBuzz').thenReturn('FizzBuzz');

        Fizzbuzz mock = (Fizzbuzz) Mockpex.createStub(Fizzbuzz.class, setting);

        System.assertEquals('FizzBuzz', mock.fizzBuzz(11), 'Return value mocking.');
    }

    class SampleException extends Exception { /* NOOP */ }

    /**
     * Can throws any Exceptions.
     */
    @isTest
    public static void SimpllyExceptionTrows_Test() {
        Mockpex setting = new Mockpex();

        setting.when('fizzBuzz').thenThrow(new SampleException());

        Fizzbuzz mock = (Fizzbuzz) Mockpex.createStub(Fizzbuzz.class, setting);

        try {
            mock.fizzBuzz(11);
        } catch (Exception e) {
            System.assert(e instanceOf SampleException);
            return;
        }
        System.assert(false, 'Must not call.');
    }

    /**
     * Stub returns match argument setting.
     */
    @isTest
    public static void EqualArgs_Test() {
        Mockpex setting = new Mockpex();
        setting.when('fizzBuzz', new List<Mockpex.ArgMatcher> { Mockpex.eqArg(15) }).thenReturn('FizzBuzz');
        setting.when('fizzBuzz', new List<Mockpex.ArgMatcher> { Mockpex.anyArg() }).thenReturn('Test');

        Fizzbuzz mock = (Fizzbuzz) Mockpex.createStub(Fizzbuzz.class, setting);

        System.assertEquals('FizzBuzz', mock.fizzBuzz(15));
        System.assertEquals('Test', mock.fizzBuzz(1));
    }

    /**
     * Stub returns match argument setting.
     */
    @isTest
    public static void EqualThrowArgs_Test() {
        Mockpex setting = new Mockpex();
        setting.when('fizzBuzz', new List<Mockpex.ArgMatcher> { Mockpex.eqArg(0) }).thenThrow(new SampleException());
        setting.when('fizzBuzz', new List<Mockpex.ArgMatcher> { Mockpex.anyArg() }).thenReturn('Test');

        Fizzbuzz mock = (Fizzbuzz) Mockpex.createStub(Fizzbuzz.class, setting);

        System.assertEquals('Test', mock.fizzBuzz(15));
        try {
            mock.fizzBuzz(0);
        } catch (Exception e) {
            return;
        }
        System.assert(false, 'Cant call');
    }

    /**
     * Checking call log.
     */
    @isTest
    public static void Verify_simplly_call_Test() {
        Mockpex setting = new Mockpex();

        setting.when('fizzBuzz').thenReturn('FizzBuzz');

        Fizzbuzz mock = (Fizzbuzz) Mockpex.createStub(Fizzbuzz.class, setting);
        
        for (Integer n = 0; n < 20; n++) {
            mock.fizzBuzz(n);
        }

        // get all log by name.
        List<Mockpex.CallLog> logs = setting.findLog('fizzBuzz');
        System.assertEquals(20, logs.size(), '20 calls.');

        // return all logs.
        for (Integer n = 0; n < 20; n++) {
            Mockpex.CallLog log = logs[n];
            System.assertEquals('fizzBuzz', log.methodName);
            System.assertEquals(Integer.class, log.argTypes[0]);
            System.assertEquals(n, log.argVals[0]);
        }

        // verify
        setting.verify('fizzBuzz', 20);

        // get target value log.
        logs = setting.findLog('fizzBuzz', new List<Mockpex.ArgMatcher> { Mockpex.eqArg(11) });
        System.assertEquals(1, logs.size(), '1 calls.');

        // match method found.
        System.assertEquals('fizzBuzz', logs[0].methodName);
        System.assertEquals(Integer.class, logs[0].argTypes[0]);
        System.assertEquals(11, logs[0].argVals[0]);

        // veryfy
        setting.verify('fizzBuzz', new List<Mockpex.ArgMatcher> { Mockpex.eqArg(11) }, 1);
    }
}
