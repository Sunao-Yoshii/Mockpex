public with sharing class Fizzbuzz {

    private static Fizzbuzz instance = new Fizzbuzz();

    public static Fizzbuzz getInstance() {
        return Fizzbuzz.instance;
    }

    public Fizzbuzz() { /* NOOP */}

    public String fizzBuzz(Integer num) {
        Boolean isFizz = Math.mod(num, 3) == 0;
        Boolean isBuzz = Math.mod(num, 5) == 0;
        if (isFizz && isBuzz) { return 'FizzBuzz'; }
        if (isFizz) { return 'Fizz'; }
        if (isBuzz) { return 'Buzz'; }
        return num.format();
    }
}