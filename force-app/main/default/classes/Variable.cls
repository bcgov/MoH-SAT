public class Variable implements Expression {
    String name { get; set; }
    Boolean value { get; set; }

    public Variable(String name) {
        this.name = name;
    }

    public Expression add(Expression expr) {
        return this;
    }

    public Expression set(String name, Boolean value) {
        if (this.name != null && this.name.equalsIgnoreCase(name)) {
            this.value = value;
        }
        
        return this;
    }

    public Boolean evaluate() {
        return value;
    }

}