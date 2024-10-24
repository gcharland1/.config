from time import sleep

import os
import shlex
import subprocess

from utils import bashUtils, solutionUtils


FREE_CPU = 3
MVN_CLEAN_INSTALL = 'mvn clean install'
SLEEP_DELAY = 0.1
VIRGO_PATH = "/home/devjava/Applications/" + \
        "virgo-tomcat-server-3.6.3.RELEASE"
VIRGO_DIR = f"{VIRGO_PATH}/repository"


class MavenHandler():
    """Maven handler to compile solutions in order"""

    # Map of the solution and it's maven clean install subprocess
    _subprocessMap = {}
    # Map of the solution and it's dependencies
    _solutionDependenciesMap = {}
    _maxSubprocessCount = 10

    def __init__(self, debug: bool = False) -> None:
        numberOfCpu = getNumberOfCpu()
        self._maxSubprocessCount = numberOfCpu - FREE_CPU \
            if numberOfCpu > 0 else 10
        self._debug = debug

    def mavenCleanInstallSolutionMap(self, printFunction=None) -> None:
        """
        Maven clean install solutions self._solutionDependenciesMap in order

        - printFunction: The function to call to update the progess on the UI
        """

        if self._solutionDependenciesMap == {}:
            return

        if printFunction is None:
            printFunction = self.printProgress()

        while 1:
            activeProcessCount = len([activeProcess for activeProcess
                                      in self._subprocessMap.values()
                                      if activeProcess.poll() is None])
            if activeProcessCount >= self._maxSubprocessCount:
                # The number of active process is exceeded
                # don't bother starting more solutions
                continue

            for solution, dependencies \
                    in self._solutionDependenciesMap.items():
                if solution in self._subprocessMap:
                    continue

                initiatedDependencies = [dependency
                                         for dependency in dependencies
                                         if dependency in self._subprocessMap]

                if sorted(initiatedDependencies) != sorted(dependencies):
                    # Not all parents are initiated
                    continue

                compiledDependencies = [dependency
                                        for dependency in initiatedDependencies
                                        if
                                        self._subprocessMap[dependency].poll()
                                        is not None]
                if sorted(compiledDependencies) != sorted(dependencies):
                    # Not all parents are done compiling
                    continue

                # All checks have passed. Initiate process ressources
                self._subprocessMap[solution] = mavenCleanInstallSolution(
                        solution,
                        self._debug)

                # Check if maximum number of processes is achieved
                activeProcessCount += 1
                if activeProcessCount == self._maxSubprocessCount:
                    break

            if len(self._solutionDependenciesMap) == len(self._subprocessMap):
                break

            printFunction()
            sleep(SLEEP_DELAY)

        # Wait for all initiated subprocesses to finish
        [subprocess.wait() for _, subprocess
         in self._subprocessMap.items()
         if subprocess is not None]
        printFunction()

    def printProgress(self):
        """
        Default print function if no other method is passed to
        mavenCleanInstallSolutionMap()
        """
        done = len([k for k, v in self._subprocessMap.items()
                    if v.poll() is not None])
        prog = len([k for k, v in self._subprocessMap.items()
                    if v.poll() is None])
        wait = len([k for k in self._solutionDependenciesMap.keys()
                    if k not in self._subprocessMap.keys()])

        print(f"\n * {done} complété\n" +
              f" * {prog} en cours\n" +
              f" * {wait} en attente")

    # Getters
    def getSubprocessMap(self) -> dict:
        return self._subprocessMap

    def getSolutionMap(self) -> dict:
        return self._solutionDependenciesMap

    # Setters
    def setSubprocessMap(self, mviMap: dict) -> None:
        self._subprocessMap = mviMap

    def setSolutionMap(self, solutionMap: dict) -> None:
        self._solutionDependenciesMap = solutionMap


def getMavenCommand(solution, debug: bool = False) -> str:
    """
    Returns the maven command to compile the specified solution

    - solution: the name of the solution
    - debug: run the command in quiet mode or not
    """

    if solutionUtils.isVirgoSolution(solution):
        cmd = f'{MVN_CLEAN_INSTALL} -P Virgo -e -fae -Dmaven.test.skip=true ' \
                f'-Ddependencies.repository={VIRGO_DIR} ' \
                '-Dvirgo.profile.phase=install'
    else:
        cmd = f'{MVN_CLEAN_INSTALL} -T 1C -P Dev ' + \
                '-e -fae -Dmaven.test.skip=true'

    if not debug:
        cmd = cmd + ' -q'

    return cmd


def getNumberOfCpu() -> int:
    """
    Returns the number of cpu's of the computer running this script
    """
    command = "/bin/bash -c \"lscpu | grep '^CPU(s):' | sed -e 's/[^0-9]//g'\""

    return int(bashUtils.execute(command, onError=-1))


def isMavenProject(path: str) -> bool:
    """
    Returns whether the path points to a maven project

    - path: the complete path to the project directory
    """

    if not os.path.exists(path):
        print(f'{path} does not exist')
        return False

    if not os.path.exists(os.path.join(path, 'pom.xml')):
        print(f'Cannot find pom.xml in {path}')
        return False

    return True


def mavenCleanInstallSolution(solution: str,
                              debug: bool = False) -> subprocess.Popen:
    """
    Returns a subprocess running the compilation of the solution

    - solution: the name of the solution to compile
    - debug: run the command in quiet mode or not
    """

    pathToSol = solutionUtils.getPathToSolution(solution)

    if not isMavenProject(pathToSol):
        return None

    command = shlex.split(
            f'/bin/bash -c "cd {pathToSol} && ' +
            f'{getMavenCommand(solution, debug)}"')
    try:
        with open(os.path.join(pathToSol, 'processRessource.log'),
                  'w+') as out, \
            open(os.path.join(pathToSol, 'processRessourceError.log'),
                 'w+') as err:
            return subprocess.Popen(command,
                                    shell=False,
                                    stdout=out,
                                    stderr=err)
    except subprocess.CalledProcessError as e:
        return f"An error occurred: {e.stderr}"
