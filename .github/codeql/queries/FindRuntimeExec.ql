/**
 * @name Find any exec method call
 * @description Diagnostic query to confirm CodeQL extracts an exec method call.
 * @kind problem
 * @problem.severity warning
 * @id custom/find-any-exec
 */

import java

from MethodAccess call
where call.getMethod().getName() = "exec"
select call, "CodeQL found a method call named exec."