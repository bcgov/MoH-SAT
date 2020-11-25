public abstract class Operator implements Expression {
    public List<Expression> children { get; private set; }

    public Operator() {
        this.children = new List<Expression>();
    }

    public Expression add(Expression expr) {
        children.add(expr);
        return this;
    }

    public Expression set(SObject obj) {
        for (Expression expr : children) {
            expr.set(obj);
        }
        return this;
    }

    public abstract Boolean evaluate();
}
