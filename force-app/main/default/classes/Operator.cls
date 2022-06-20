public abstract class Operator implements Expression {
    public List<Expression> children { get; private set; }

    public Operator() {
        this.children = new List<Expression>();
    }

    public virtual Expression add(Expression expr) {
        children.add(expr);
        return this;
    }

    public virtual Expression set(String name, Boolean value) {
        for (Expression expr : children) {
            expr.set(name, value);
        }
        return this;
    }

    public abstract Boolean evaluate();
}