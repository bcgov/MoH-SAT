public class AndOperator extends Operator {
    
    public override Boolean evaluate() {
        for (Expression expr : children) {
            if (!expr.evaluate()) {
                return false;
            }
        }
        
        return true;
    }

}
