/**
 * Data structure for represnting boolean expressions as an abstract syntax tree. 
 */
public interface Expression {

    Expression add(Expression expr);

    Expression set(String name, Boolean value);

    Boolean evaluate();
    
}