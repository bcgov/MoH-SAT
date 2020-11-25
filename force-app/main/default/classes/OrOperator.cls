public class OrOperator extends Operator {

    public override Boolean evaluate() {
        for (Expression expr : children) {
            if (expr.evaluate()) {
                return true;
            }
        }

        return false;
    }

}
