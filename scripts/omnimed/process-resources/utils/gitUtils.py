from utils import bashUtils

from resources.omnimedConstants import PATH_TO_OMNIMED_SOLUTION


def getLocalModificationList() -> list:
    """
    Returns the list of solutions containing local modifications
    """
    cmd = f"cd {PATH_TO_OMNIMED_SOLUTION} && " + \
        "git status --short | grep 'omnimed-' " + \
        "| awk '{print $2}' | cut -d/ -f1 | sort | uniq"

    return [solution for solution
            in bashUtils.execute(cmd, onError="").split('\n')
            if solution != ""]


def getModifiedSolutionList() -> list:
    """
    Returns the list of solutions containing git diff not present in
    upstream/fix-develop.
    """
    cmd = f"cd {PATH_TO_OMNIMED_SOLUTION} && " + \
        "git --no-pager diff --name-only upstream/fix-develop...HEAD" + \
        "| cut -d/ -f 1 | sort | uniq | grep 'omnimed'"

    return [solution for solution
            in bashUtils.execute(cmd, onError="").split('\n')
            if solution != ""]


def getLastCommitHashForSolution(solution: str,
                                 saveToFile: bool = False) -> str:
    """
    Returns the commit hash of the last commit for the
    provided solution
    """
    cmd = f"cd {PATH_TO_OMNIMED_SOLUTION} && " + \
          f"git --no-pager log -1 --pretty=format:%H -- ./{solution}"

    if saveToFile:
        cmd += f" | tee {solution}/sha1.sum"

    return bashUtils.execute(cmd, onError="")
