/**
 * @name Find method calls in CodeQL validation fixture
 * @description Diagnostic query to confirm CodeQL extracts calls from the controlled fixture.
 * @kind problem
 * @problem.severity warning
 * @id custom/find-fixture-method-calls
 */

import java

from MethodAccess call
where
  call.getEnclosingCallable().getDeclaringType().getName() =
    "CodeQLCommandInjectionFixture"
select call, "CodeQL found a method call inside CodeQLCommandInjectionFixture."