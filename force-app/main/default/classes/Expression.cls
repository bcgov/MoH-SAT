public interface Expression {

    Expression add(Expression expr);

    Expression set(SObject obj);

    Boolean evaluate();
    
}
