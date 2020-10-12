/**
 * Apex mock library.
 */
@IsTest
public with sharing class Mockpex implements System.StubProvider {

    public List<CallLog> callLogs = new List<CallLog> ();
    public List<MethodStub> methods = new List<MethodStub> ();

    public MethodStubCreator when(String methodName) {
        return new MethodStubCreator(this, methodName);
    }

    public MethodStubCreator when(String methodName, List<ArgMatcher> argMatchers) {
        return new MethodStubCreator(this, methodName, argMatchers);
    }

    public Object handleMethodCall(
        Object stubbedObject,
        String stubbedMethodName,
        Type returnType, 
        List<Type> listOfParamTypes, 
        List<String> listOfParamNames, 
        List<Object> listOfArgs
    ) {
        // logging to call log.
        this.callLogs.add(new CallLog(stubbedMethodName, listOfParamTypes, listOfArgs));

        // search method stubs
        for (MethodStub stub : this.methods) {
            if (stub.match(stubbedMethodName, listOfParamTypes, listOfArgs)) {
                return stub.result();
            }
        }

        // no matchs
        return null;
    }

    /**
     * Method call log object.
     */
    public class CallLog {
        public String methodName { get; set; }
        public List<Type> argTypes { get; set; }
        public List<Object> argVals { get; set; }
        public CallLog(String methodName, List<Type> argTypes, List<Object> argVals) {
            this.methodName = methodName;
            this.argTypes = argTypes;
            this.argVals = argVals;
        }
    }

    /**
     * verify no args calls. 
     * @param  methodName methodName description
     * @param  times      times description
     * @return            return description
     */
    public void verify(String methodName, Integer times) {
        Integer num = this.findLog(methodName).size();
        System.assertEquals(times, num, 'Method ' + methodName + ' are exprct calls ' + times + ' but was ' + num);
    }

    /**
     * search log by method name
     * @param  methodName methodName description
     * @return            return description
     */
    public List<CallLog> findLog(String methodName) {
        List<CallLog> result = new List<CallLog>();
        for (CallLog log : this.callLogs) {
            if (log.methodName == methodName) {
                result.add(log);
            }
        }
        return result;
    }

    /**
     * verify no args calls.
     * @param  methodName methodName description
     * @param  matchers   matchers description
     * @param  times      times description
     * @return            return description
     */
    public void verify(String methodName, List<ArgMatcher> matchers, Integer times) {
        Integer num = this.findLog(methodName, matchers).size();
        System.assertEquals(times, num, 'Method ' + methodName + ' are exprct calls ' + times + ' but was ' + num);
    }

    /**
     * search log by method name
     * @param  methodName methodName description
     * @return            return description
     */
    public List<CallLog> findLog(String methodName, List<ArgMatcher> matchers) {
        List<CallLog> result = new List<CallLog>();
        for (CallLog log : this.callLogs) {
            if (log.argVals == null || matchers.size() != log.argVals.size()) {
                continue;
            }
            if (log.methodName != methodName) {
                continue;
            }

            Integer argMatchCount = 0;
            for (Integer i = 0; i < matchers.size(); i++) {
                if (matchers[i].match(log.argTypes[i], log.argVals[i])) {
                    argMatchCount++;
                }
            }
            if (argMatchCount == matchers.size()) {
                result.add(log);
            }
        }
        return result;
    }

    /**
     * Mock method definition.
     */
    public virtual class MethodStub {
        public String name { get; set; }
        public Object returnValue { get; set; }
        public MethodStub(String name, Object returnValue) {
            this.name = name;
            this.returnValue = returnValue;
        }
        public MethodStub(String name, Object returnValue, List<ArgMatcher> argMatchers) {
            this.name = name;
            this.returnValue = returnValue;
        }
        public virtual Boolean match(String methodName, List<Type> argTypes, List<Object> argValues) {
            return this.name == methodName;
        }
        public virtual Object result() {
            return this.returnValue;
        }
    }

    private virtual class ArgMethodStub extends MethodStub {
        public List<ArgMatcher> argMatchers;
        public ArgMethodStub(String name, List<ArgMatcher> argMatchers, Object returnValue) {
            super(name, returnValue);
            this.argMatchers = argMatchers;
        }
        public override Boolean match(String methodName, List<Type> argTypes, List<Object> argValues) {
            if (argMatchers.isEmpty() && (argValues == null || argValues.isEmpty())) {
                return super.match(methodName, argTypes, argValues);
            }
            if (argValues.size() != argMatchers.size()) {
                return false;
            }
            for (Integer i = 0; i < argMatchers.size(); i++) {
                if (!argMatchers[i].match(argTypes[i], argValues[i])) {
                    return false;
                }
            }
            return super.match(methodName, argTypes, argValues);
        }
    }

    /**
     * throws exception method stub.
     */
    private class ExceptMethodStub extends MethodStub {
        public Exception throwValue;
        public ExceptMethodStub(String name, Exception throwValue) {
            super(name, null);
            this.throwValue = throwValue;
        }
        override public Object result() {
            throw this.throwValue;
        }
    }

    private class ExceptArgMethodStub extends ArgMethodStub {
        public List<ArgMatcher> argMatchers;
        public Exception throwValue;
        public ExceptArgMethodStub(String name, List<ArgMatcher> argMatchers, Exception returnValue) {
            super(name, argMatchers, null);
            this.throwValue = returnValue;
        }
        override public Object result() {
            throw this.throwValue;
        }
    }

    /**
     * Method stub creation helper.
     */
    public class MethodStubCreator {
        private String methodName;
        private Mockpex setting;
        private List<ArgMatcher> argMatchers;

        public MethodStubCreator(Mockpex setting, String methodName) {
            this.setting = setting;
            this.methodName = methodName;
            this.argMatchers = null;
        }

        public MethodStubCreator(Mockpex setting, String methodName, List<ArgMatcher> argMatchers) {
            this.setting = setting;
            this.methodName = methodName;
            this.argMatchers = argMatchers;
        }

        public void thenReturn(Object value) {
            if (this.argMatchers == null || this.argMatchers.isEmpty()) {
                this.setting.methods.add(new MethodStub(this.methodName, value));
                return;
            }
            this.setting.methods.add(new ArgMethodStub(this.methodName, this.argMatchers, value));
        }

        public void thenThrow(Exception throwVal) {
            if (this.argMatchers == null || this.argMatchers.isEmpty()) {
                this.setting.methods.add(new ExceptMethodStub(this.methodName, throwVal));
                return;
            }
            this.setting.methods.add(new ExceptArgMethodStub(this.methodName, this.argMatchers, throwVal));
        }
    }

    public interface ArgMatcher {
        Boolean match(Type argType, Object argValue);
    }

    private class AnyArgMatcher implements ArgMatcher {
        public Boolean match(Type argType, Object argValue) {
            return true;
        }
    }

    private class EqualArgMatcher implements ArgMatcher {
        private Object value;
        public EqualArgMatcher(Object value) {
            this.value = value;
        }
        public Boolean match(Type argType, Object argValue) {
            if (this.value == null) {
                return argValue == null;
            }
            return this.value.equals(argValue);
        }
    }

    public static ArgMatcher anyArg() {
        return new AnyArgMatcher();
    }

    public static ArgMatcher eqArg(Object value) {
        return new EqualArgMatcher(value);
    }

    public static Object createStub(Type stubObjectType, Mockpex setting) {
        return Test.createStub(stubObjectType, setting);
    }
}
