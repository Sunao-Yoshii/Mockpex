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
}
