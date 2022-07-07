@isTest
public class ExpressionTest {
    
    @isTest
    static void test_and_operator() {
        // 1 AND 2
        Expression expr = 
            new AndOperator()
                .add(new Variable('1'))
                .add(new Variable('2'));
        
        // TRUE AND TRUE
        expr.set('1', true);
        expr.set('2', true);
        system.assertEquals(true, expr.evaluate());
        
        // FALSE AND TRUE
        expr.set('1', false);
        expr.set('2', true);
        system.assertEquals(false, expr.evaluate());
        
        // FALSE AND FALSE
        expr.set('1', false);
        expr.set('2', false);
        system.assertEquals(false, expr.evaluate());
    }

    @isTest
    static void test_or_operator() {
        // 1 OR 2
        Expression expr = 
            new OrOperator()
                .add(new Variable('1'))
                .add(new Variable('2'));
        
        // TRUE OR TRUE
        expr.set('1', true);
        expr.set('2', true);
        system.assertEquals(true, expr.evaluate());
        
        // FALSE OR TRUE
        expr.set('1', false);
        expr.set('2', true);
        system.assertEquals(true, expr.evaluate());
        
        // FALSE OR FALSE
        expr.set('1', false);
        expr.set('2', false);
        system.assertEquals(false, expr.evaluate());
    }

    @isTest
    static void test_op_chaining() {
        // 1 OR (2 AND 3)
        Expression expr = 
            new OrOperator()
                .add(new Variable('1'))
                .add(
                    new AndOperator()
                        .add(new Variable('2'))
                        .add(new Variable('3'))
                );
        
        // TRUE OR (TRUE AND TRUE)
        expr.set('1', true);
        expr.set('2', true);
        expr.set('3', true);
        system.assertEquals(true, expr.evaluate());
        
        // TRUE OR (FALSE AND TRUE)
        expr.set('1', true);
        expr.set('2', true);
        expr.set('3', false);
        system.assertEquals(true, expr.evaluate());
        
        // FALSE OR (FALSE AND TRUE)
        expr.set('1', false);
        expr.set('2', false);
        expr.set('3', true);
        system.assertEquals(false, expr.evaluate());
    }
}