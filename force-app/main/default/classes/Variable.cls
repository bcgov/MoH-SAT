public class Variable implements Expression {
    String name { get; set; }
    Boolean value { get; set; }

    public Variable(String name) {
        this.name = name;
        this.value = false;
        System.debug('### Variable - CREATED with name: "' + name + '"');
    }

    public Expression add(Expression expr) {
        return this;
    }

    public Expression set(String name, Boolean value) {
        System.debug('### Variable.set - Trying to set name: "' + name + 
                     '" | this.name: "' + this.name + '"');
        if (this.name != null && this.name.equalsIgnoreCase(name)) {
            this.value = value;
            System.debug('### Variable.set - MATCHED! Set value: ' + value);
        } else {
            System.debug('### Variable.set - NO MATCH. Skipping.');
        }
        return this;
    }

    public Boolean evaluate() {
        Boolean result = value != null ? value : false;
        System.debug('### Variable.evaluate - name: "' + name + 
                     '" | value: ' + value + 
                     ' | returning: ' + result);
        return result;
    }
}