/**
 * @name Find all method calls
 * @description Diagnostic query to verify Java method calls exist in the CodeQL database.
 * @kind problem
 * @problem.severity warning
 * @id custom/find-all-method-calls
 */

import java

from MethodAccess call
select call, "CodeQL found a Java method call."