/**
 * @name Find Runtime.exec calls
 * @description Diagnostic query for Phase 3 CodeQL validation.
 * @kind problem
 * @problem.severity warning
 * @id custom/find-runtime-exec
 */

import java

from MethodAccess call
where
  call.getMethod().getDeclaringType().hasQualifiedName("java.lang", "Runtime") and
  call.getMethod().getName() = "exec"
select call, "Runtime.exec call found by diagnostic CodeQL query."