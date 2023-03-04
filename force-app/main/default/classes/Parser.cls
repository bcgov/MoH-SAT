/**
 * Parses a boolean expression string such as "AND(1, 2, OR(3, 4))" into an abstract syntax tree.
 */
public class Parser {
    public class ParsingException extends Exception {}
	
    public static Expression parse(String boolExprStr) {
        Stack stack = new Stack();
		String[] tokens = tokenize(boolExprStr);
		Integer ptr = 0;
		
		while (ptr < tokens.size()) {
			String currentToken = '';
            
            // Consume tokens until a right parenthesis is encountered.

			while (!isRParen(currentToken)) {
				currentToken = tokens[ptr];
				Object currentObj;
				
				if (isLogicalOp(currentToken) && isAnd(currentToken)) {
					currentObj = new AndOperator();
                } 

                else if (isLogicalOp(currentToken) && isOr(currentToken)) {
                    currentObj = new OrOperator();
                }
				
				else if (isNum(currentToken)) {
                    currentObj = new Variable(currentToken);
 				}
				
				else if (isParen(currentToken)) {
					currentObj = currentToken;
				} 
				
				stack.push(currentObj);
				ptr++;
			}
			
			// Pop stack until a left parenthesis is encountered.
			
			List<Expression> exprs = new List<Expression>();
			Boolean inOpParens = true;
			
			while (inOpParens) {
				Object popped = stack.pop();
				
				if (popped == null) throw new ParsingException('Unmatched parenthesis.');
				
				if (popped instanceof Expression) {
					exprs.add((Expression) popped);
					inOpParens = true;	
				}
				
				else if (isRParen(popped)) {
					inOpParens = true;
				}
				
				else if (isLParen(popped)) {
					inOpParens = false;
				} 
			}
			
			// Pop once more to retrieve the logical operator then create the expression.
			
			Object logicalOp = stack.pop();
			
			if (!(logicalOp instanceof Operator)) { 
				throw new ParsingException(); 
			}
			
			Operator compExpr = (Operator) logicalOp;
			
			for (Expression expr : exprs) {
				compExpr.add(expr);
			}
			
			// push to stack new expression
			stack.push(compExpr);
		}
		
		Expression expr = (Expression) stack.pop();
		
		if (stack.pop() != null) throw new ParsingException('Boolean expression cannot be fully parsed.');
		
		return expr;
    }
    
    public static List<String> tokenize(String boolExprStr) {
        List<String> tokens = new List<String>();
		
		boolExprStr = boolExprStr.replace(' ', '');
		
		Integer startIndex = 0;
		Integer endIndex = startIndex + 1;
			
		while (startIndex < boolExprStr.length()) {
			String word = boolExprStr.substring(startIndex, endIndex);
		
			if (word.toLowerCase().equals('a')) {
				endIndex = endIndex + 2;
			} else if (word.toLowerCase().equals('o')) {
				endIndex = endIndex + 1;
			} 
			
			while(isNum(word) && isNum(boolExprStr.substring(endIndex, endIndex + 1))){
				endIndex++;
			}
			
			word = boolExprStr.substring(startIndex, endIndex);
			
			if (isToken(word) || isComma(word)) {
				if (isComma(word)) {
					startIndex = startIndex + 1;
					endIndex = startIndex + 1;
				} else {
					tokens.add(word);
					startIndex = endIndex;
					endIndex = endIndex + 1;	
				}
			} else {
				throw new ParsingException('Unrecognized token: ' + word);
			}
		}
		
		return tokens;
    }

    private static Boolean isComma(String word) {
		return word == ',';
	}
	
	private static Boolean isNum(String word) {
		return word.isNumeric();
	}
	
	private static Boolean isLogicalOp(String word) {
		return isAnd(word) || isOr(word);
	}
	
	private static Boolean isAnd(String word) {
		return word == 'AND';
	}
	
	private static Boolean isOr(String word) {
		return word == 'OR';
	}
	
	private static Boolean isParen(String word) {
		return isLParen(word) || isRParen(word);
	}
	
	private static Boolean isLParen(String word) {
		return word == '(';
	}
	
	private static Boolean isRParen(String word) {
		return word == ')';
	}
	
	private static Boolean isLParen(Object o) {
		return (o instanceof String) && isLParen((String) o);
	}
	
	private static Boolean isRParen(Object o) {
		return (o instanceof String) && isRParen((String) o);
	}
	
	private static Boolean isToken(String word) {
		if 			(isNum(word)) 		return true;
		else if 	(isAnd(word)) 		return true;
		else if 	(isOr(word))		return true;
		else if 	(isLParen(word)) 	return true;
		else if 	(isRParen(word)) 	return true;
		else 							return false;
	}
	
	private class Stack {
		private List<Object> arr;
		
		public Stack() {
			this.arr = new List<Object>();
		}
		
		public Stack push(Object obj) {
			arr.add(obj);
			return this;
		}
		
		public Object pop() {
			return !arr.isEmpty() ? arr.remove(this.arr.size() - 1) : null;		
		}
	}
}