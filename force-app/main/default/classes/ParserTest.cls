@isTest
public class ParserTest {

    @isTest
    static void test_parse() {
        Expression expr = Parser.parse('AND(1, 2)');
        system.assert(expr instanceof AndOperator);
        
        expr = Parser.parse('OR(1, 2)');
        system.assert(expr instanceof OrOperator);
        
        expr = Parser.parse('AND(1, 2, OR(3, 4))');
        system.assert(expr instanceof AndOperator);
    }

    @isTest
    static void test_unmatched_paren() {
        try {
            Parser.parse('AND(1, 2)))');
            system.assert(false, 'An expected exception was not thrown.');
        } catch (Parser.ParsingException e) {
            system.assertEquals('Unmatched parenthesis.', e.getMessage());
        }
    }

    @isTest
    static void test_unrecognized_token() {
        try {
            Parser.parse('EQUALS(1, 2)');
            system.assert(false, 'An expected exception was not thrown.');
        } catch (Parser.ParsingException e) {
            system.assertEquals('Unrecognized token: E', e.getMessage());
        }
    }
    
    @isTest
    static void test_unable_to_parse() {
        try {
            Parser.parse('AND AND(1, 2)');
            system.assert(false, 'An expected exception was not thrown.');
        } catch (Parser.ParsingException e) {
            system.assertEquals('Boolean expression cannot be fully parsed.', e.getMessage());
        }
    }
}
