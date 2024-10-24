import os

from utils import solutionUtils

CURRENT_PATH = os.path.dirname(os.path.abspath(__file__))
solutionUtils.PATH_TO_OMNIMED_SOLUTION = os.path.join(
        CURRENT_PATH,
        'resources/mock-omnimed-solution/')


def test_addDependenciesToDependencyMap_emptyMap() -> None:
    dependencyMap = {}
    expectedDependencyMap = {}

    actualDependencyMap = \
        solutionUtils.addDependenciesToDependencyMap(dependencyMap)

    assert actualDependencyMap == expectedDependencyMap


def test_addDependenciesToDependencyMap_noParents() -> None:
    dependencyMap = {'omnimed-apidefinition-prescribeit': []}
    expectedDependencyMap = {'omnimed-apidefinition-prescribeit': []}

    actualDependencyMap = \
        solutionUtils.addDependenciesToDependencyMap(dependencyMap)

    assert actualDependencyMap == expectedDependencyMap


def test_addDependenciesToDependencyMap_withParents() -> None:
    dependencyMap = {'omnimed-frontend-prescribeit': [
        'omnimed-api-prescribeit',
        'omnimed-apidefinition-prescribeit']
                     }

    expectedDependencyMap = {'omnimed-apidefinition-prescribeit': [],
                             'omnimed-api-prescribeit': [
        'omnimed-apidefinition-prescribeit'],
                             'omnimed-frontend-prescribeit': [
        'omnimed-api-prescribeit',
        'omnimed-apidefinition-prescribeit']
                             }

    actualDependencyMap = \
        solutionUtils.addDependenciesToDependencyMap(dependencyMap)

    assert actualDependencyMap == expectedDependencyMap


def test_generateDependencyMap() -> None:
    solutionList = ['omnimed-apidefinition-prescribeit',
                    'omnimed-api-prescribeit',
                    'omnimed-frontend-prescribeit']
    expectedDependencyMap = {
            'omnimed-api-prescribeit': [
                'omnimed-apidefinition-prescribeit'],
            'omnimed-apidefinition-prescribeit': [],
            'omnimed-frontend-prescribeit': [
                'omnimed-api-prescribeit',
                'omnimed-apidefinition-prescribeit']
            }

    actualDependencyMap = solutionUtils.generateDependencyMap(solutionList)
    assert actualDependencyMap == expectedDependencyMap


def test_generateDependencyMap_emptyList() -> None:
    solutionList = []
    expectedDependencyMap = {}

    actualDependencyMap = solutionUtils.generateDependencyMap(solutionList)
    assert actualDependencyMap == expectedDependencyMap


def test_getDependenciesForSolution() -> None:
    solution = 'omnimed-frontend-prescribeit'
    pathToSolution = os.path.join(solutionUtils.PATH_TO_OMNIMED_SOLUTION,
                                  solution)

    expectedDependencyList = ['omnimed-api-prescribeit',
                              'omnimed-apidefinition-prescribeit']

    actualDependencyList = solutionUtils.getDependenciesForSolution(
            pathToSolution)

    assert actualDependencyList == expectedDependencyList


def test_getDependenciesForSolution_doesNotExist() -> None:
    solution = 'omnimed-patate-prescribeit'
    pathToSolution = os.path.join(solutionUtils.PATH_TO_OMNIMED_SOLUTION,
                                  solution)

    expectedDependencyList = []

    actualDependencyList = solutionUtils.getDependenciesForSolution(
            pathToSolution)

    assert actualDependencyList == expectedDependencyList


def test_getPathToSolution() -> None:
    solution = 'omnimed-api-prescribeit'
    expectedPath = solutionUtils.PATH_TO_OMNIMED_SOLUTION + \
        'omnimed-api-prescribeit'

    actualPath = solutionUtils.getPathToSolution(solution)

    assert actualPath == expectedPath


def test_getSolutionList() -> None:
    expectedSolutionList = ['omnimed-frontend-prescribeit',
                            'omnimed-apidefinition-prescribeit',
                            'omnimed-api-prescribeit']
    sort = False

    actualSolutionList = solutionUtils.getSolutionList(sort)

    assert actualSolutionList == expectedSolutionList


def test_getSolutionList_sorted() -> None:
    expectedSolutionList = ['omnimed-api-prescribeit',
                            'omnimed-apidefinition-prescribeit',
                            'omnimed-frontend-prescribeit']
    sort = True

    actualSolutionList = solutionUtils.getSolutionList(sort)

    assert actualSolutionList == expectedSolutionList

# def test_removeUnchangedSolutionsFromMap() -> None:
