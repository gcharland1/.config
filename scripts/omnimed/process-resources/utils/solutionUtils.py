import os
import re

from utils import gitUtils

from resources.omnimedConstants import PATH_TO_OMNIMED_SOLUTION, \
        SOLUTION_PREFIX, SHA1_FILE

VIRGO_SOLUTION_MATCHER = re.compile(
        '^omnimed-(common|engine|healthrecord|interfaces|mock|shared|utils)$')


def addDependenciesToDependencyMap(dependencyMap: dict) -> dict:
    """
    Adds the dependencies and their dependencies to the provided
    dependency map and returns the updated map.

    - dependencyMap: The map of each solution and their dependencies
    """
    while 1:
        # Get all unique dependencies not present as a Key
        # in the provided map
        dependenciesSolutionList = [dependency for dependency
                                    in dict.fromkeys(
                                        sum(dependencyMap.values(), []))
                                    if dependency not in dependencyMap]

        # Exit when all dependencies are present as a key in the map
        if len(dependenciesSolutionList) == 0:
            return dependencyMap

        for p in dependenciesSolutionList:
            dependencyMap[p] = getDependenciesForSolution(
                    getPathToSolution(p))


def generateDependencyMap(solutionList: list) -> dict:
    """
    Returns a map of all the dependencies recursively
    for the provided solutionList

    - solutionList: The list of solutions to generate the dependency
        map for.
    """
    dependencyMap = {solution:
                     getDependenciesForSolution(
                         getPathToSolution(solution))
                     for solution in solutionList}

    dependencyMap = addDependenciesToDependencyMap(dependencyMap)

    return dependencyMap


def getDependenciesForSolution(pathToSolution: str) -> list:
    """
    Returns the content of the solutionDependencies.txt file
    for the given solution as a list

    - pathToSolution: The path to the solution
    """
    dependenciesFile = os.path.join(pathToSolution,
                                    'solutionDependencies.txt')

    dependencies = []
    if not os.path.exists(dependenciesFile):
        return dependencies

    with open(dependenciesFile, 'r') as file:
        dependencies = [line.strip() for line in file
                        if line.strip() != '']

    return dependencies


def getSolutionList(sort: bool = False) -> list:
    """
    Returns all the solutions present in Omnimed-Solution as a list

    - sort: Sort the output alphabetically
    """
    solutionList = [solution for solution
                    in os.listdir(PATH_TO_OMNIMED_SOLUTION)
                    if solution.startswith(SOLUTION_PREFIX)]

    if sort:
        solutionList = sorted(solutionList)

    return solutionList


def getPathToSolution(solutionName: str) -> str:
    """
    Returns the complete path to the provided solution

    - solutionName: The name of the solution
    """
    return os.path.join(
            PATH_TO_OMNIMED_SOLUTION,
            solutionName)


def isVirgoSolution(solutionName) -> str:
    """
    Returns whether a solution is based on Virgo

    - solutionName: The name of the solution
    """
    return VIRGO_SOLUTION_MATCHER.match(solutionName)


def removeUnchangedSolutionsFromMap(dependencyMap: dict) -> dict:
    """
    Pops the unchanged solutions from the given dependencyMap by comparing
    the sha1.sum file for the solution with the current checksum.

    If a solution's dependency has changed, the solution is kept in the map
    even if it is unchanged

    - dependencyMap: The map of solutions and their dependencies
    """
    unchangedSolutionList = []
    for solution in dependencyMap.keys():
        pathToSolution = getPathToSolution(solution)
        pathToShaw1 = os.path.join(pathToSolution, SHA1_FILE)
        sha1 = None
        if not os.path.exists(pathToShaw1):
            continue

        with open(pathToShaw1, 'r') as sha1File:
            sha1 = sha1File.readline().strip()

        sha2 = gitUtils.getLastCommitHashForSolution(solution, False)
        if sha1 == sha2:
            unchangedSolutionList.append(solution)

    unchangedLength = -1
    while unchangedLength != len(unchangedSolutionList):
        unchangedLength = len(unchangedSolutionList)
        unchangedSolutionList = [
                solution for solution, dependencies in dependencyMap.items()
                if not any(
                    dependency
                    for dependency in dependencies
                    if dependency not in unchangedSolutionList)
                and solution in unchangedSolutionList]

    filteredDependencyMap = {}
    for solution, dependencies in dependencyMap.items():
        unchangedParents = [dependency for dependency in dependencies
                            if dependency not in unchangedSolutionList]

        if solution not in unchangedSolutionList or len(unchangedParents) > 0:
            filteredDependencyMap[solution] = unchangedParents

    return filteredDependencyMap
