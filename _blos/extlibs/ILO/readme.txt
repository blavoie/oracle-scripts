Instrumentation Library for Oracle
Frequently Asked Questions


What is the Instrumentation Library for Oracle?

  The Instrumentation Library for Oracle (ILO) is a set of
  PL/SQL packages containing functions that help developers of Oracle
  applications improve the performance diagnosability of their code.
  
  Originally developed at Hotsos, Method R now holds the copyright to the code. 
  http://www.prweb.com/releases/2008/05/prweb839554.htm
  
  All future maintenance and development of this software will be managed by
  Method R through the infrastructure at SourceForge. 
  http://sourceforge.net/projects/hotsos-ilo
  

Why should I use ILO?

  The benefits of instrumenting code with ILO include:

  - It's very easy for operators and analysts running ILO-instrumented
	applications to profile the exact duration of a specified business task.
	Imagine that a user complains that "adding an employee" in an HR system is
	too slow. With ILO instrumentation, it's trivially easy for a
	performance analyst to obtain exactly the Oracle extended SQL trace data
	he needs to diagnose and repair the user's specific problem.

  - Developers no longer need to worry about understanding when or why to use
	DBMS_APPLICATION_INFO or DBMS_SESSION to register parts of their
	applications with the Oracle database.

  - Developers no longer need to worry about inserting lines of code into
	their applications to manage Oracle's "extended SQL tracing" feature (also
	known as 10046 tracing, DBMS_SUPPORT tracing, and DBMS_MONITOR tracing).


What versions of Oracle will ILO work with?

  ILO requires Oracle 9.2.0.1 or above.


Can I use ILO in Oracle Shared Server environments?

  Yes. In an Oracle Shared Server environment, the database calls for a single
  business task might be spread across several Oracle processes, which in turn
  means that the trace records of those calls can be spread across several
  Oracle trace files. In such a case, you'll be able to identify the business
  task by name in one of the trace files (because ILO_TASK.BEGIN_TASK
  writes the task name into the trace file) and then use Oracle's trcsess tool
  to extract the relevant information into a single trace file.


Can I use ILO in multi-tier web application environments?

  Yes, but you'll need more than ILO to measure end-user response times
  in multi-tier web applications. We're studying means of instrumenting
  Apache-based web applications.


What problem are we trying to solve with ILO?

  When Oracle application code written in SQL or PL/SQL has performance
  problems, they can be very difficult to diagnose and repair. The ILO
  project gives application developers one of the tools they need to
  instrument their applications so that the diagnosis and repair process
  becomes much simpler. ILO is designed to make the job of performance
  instrumentation very simple for the application developer.


How does ILO work?

  All the application developer needs to do is mark the beginnings and endings
  of business tasks. For example, imagine that a developer is writing code
  that a user will later regard as code that adds an employee to the HR
  database. Using ILO, the developer will mark the code path as
  follows:

      BEGIN
  >     ILO_TASK.BEGIN_TASK('HR', 'Add employee', '', rec.name);
        -- code to add the employee goes here
  >     ILO_TASK.END_TASK;
      END;

  The lines marked with '>' are the only thing special that the developer
  needs to learn to do.
  
  As a result of doing this small amount of extra work, the code becomes
  capable of writing its own response time history into an Oracle table, and
  writing the details of those execution timings to Oracle trace files. The
  trace files created by a ILO-instrumented application contain extra
  information that allow performance analysts to determine the precise mapping
  of trace data lines to tasks with names that your business people understand.


What's special about ILO?

  ILO sets a standard for using DBMS_APPLICATION_INFO and DBMS_SESSION
  to register database calls, and for using Oracle's extended SQL trace
  feature to profile the performance of specified business tasks. ILO
  takes all the complexity out of solving several very common problems,
  including:

  - With ILO, you can track the performance of any business task on
	your system, and you can report on system performance in exactly the
	language your management wants to hear: response time for specific
	business tasks.

  - With ILO, your Oracle trace files will be properly time-scoped and
	won't contain unwanted events like the 'SQL*Net message from client'
	events that commonly plague trace files.

  - With ILO, your developers don't have to learn about why or when to
	use DBMS_APPLICATION_INFO or DBMS_SESSION to register their applications
	with the database.

  - ILO contains hooks to other Method R tools that allow you to do
	things like store response time histories and report on performance trends
	for specific tasks, and profile specific tasks or subtasks within large
	trace files.
  

How stable are the ILO package definitions?

  We've tried very hard to ensure that the procedure call signatures in the
  ILO_TASK package will be permanently stable. This is the only
  ILO package that contains procedures and functions that an
  application developer should call directly. Our goal is that once a
  developer instruments a block of code, a new ILO release will never
  force that developer to revisit his instrumented code.
  
  However, we reserve the right to alter any of the procedure call signatures
  in the following packages:

	- ILO_SYSUTIL
	- ILO_UTIL
	- ILO_TIMER

  And we reserve the right to alter the implementation details for any package
  we distribute.
  
  NOTE: As of version 2.1, we have moved to a more open naming convention, and
  therefore raised the possibility of problems with existing implementations. 
  We have addressed this through the use of synonyms to provide backward 
  compatibility. 


How does the developer turn trace on with ILO?

  The job of turning trace on and off is normally one that is performed at
  application runtime, long after the developer's involvement in the project
  has occurred. The BEGIN_TASK call checks to see whether someone has
  expressed the intent to trace a specific MODULE/ACTION pair by calling 
  ILO_TIMER.GET_CONFIG. This method determines which tasks should be 
  traced.
  
  A developer who wishes to unit test his code can call 
  ILO_TIMER.SET_MARK_ALL_TASKS_INTERESTING(TRUE,TRUE) to override the
  normal GET_CONFIG schedule, but calls to this method are typically not going
  to be present in production code unless they are implemented as menu options
  (for example, Help > Debug > Trace All). The decision about whether or not
  to trace should be reserved until runtime.
