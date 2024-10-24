import os

from utils import bashUtils

BASE_DOCKER_IMAGE_ARTIFACT_LIST = [
        "omnimed-docker-alpine-autofs",
        "omnimed-docker-cert-manager/omnimed.docker.cert.manager.jdk7",
        "omnimed-docker-cert-manager/omnimed.docker.cert.manager.jdk11",
        "omnimed-docker-config-feeder",
        "omnimed-docker-config-wait",
        "omnimed-docker-postgresql-init",
        "omnimed-docker-kafka-connect-elasticsearch",
        "omnimed-docker-kafka-connect-oracle",
        "omnimed-docker-kafka-connect-postgres",
        "omnimed-docker-karaf",
        "omnimed-docker-virgo",
        "omnimed-docker-virgo-slave",
        "omnimed-docker-frontend",
        "omnimed-docker-sftp",
        "omnimed-docker-stack/omnimed.docker.stack.tinytots",
        "omnimed-cas"
        ]
BASE_DOCKER_IMAGE_SOLUTION_LIST = [
        "omnimed-docker-alpine-autofs",
        "omnimed-docker-cert-manager",
        "omnimed-docker-config-feeder",
        "omnimed-docker-config-wait",
        "omnimed-docker-postgresql-init",
        "omnimed-docker-kafka-connect-elasticsearch",
        "omnimed-docker-kafka-connect-oracle",
        "omnimed-docker-kafka-connect-postgres",
        "omnimed-docker-karaf",
        "omnimed-docker-virgo",
        "omnimed-docker-virgo-slave",
        "omnimed-docker-frontend",
        "omnimed-docker-sftp",
        "omnimed-docker-stack",
        "omnimed-cas"
        ]
DOCKER_CMD = "docker build --build-arg " + \
        "DOCKER_REPOSITORY_URL=artifacts.omnimed.com/docker . -t " + \
        "artifacts.omnimed.com/docker/{artifact}:{version}"

PATH_TO_HOME = os.path.expanduser('~')
PATH_TO_OMNIMED_SOLUTION = os.path.join(PATH_TO_HOME, 'git/Omnimed-solutions')


def buildBaseDockerImages() -> None:
    """
    Builds all the base docker images in order
    """
    for solution in BASE_DOCKER_IMAGE_ARTIFACT_LIST:
        artifact = getArtifactNameFromSolution(solution)
        cmd = DOCKER_CMD.format(artifact=artifact, version="0.0.0")
        cmd = f"cd {PATH_TO_OMNIMED_SOLUTION}/{solution} && {cmd}"
        if bashUtils.execute(cmd, onError=None) is None:
            print(f"Build basedockerImage failed for solution {solution}\n")


def getArtifactNameFromSolution(pathToSolution: str) -> str:
    """
    Returns the name of the artifact to used based on the path to the artifact

    - pathToSolution: the path to the given solution
    """
    if len(pathToSolution.split("/")) == 1:
        return pathToSolution.split("/")[0]

    return pathToSolution.split("/")[1].replace(".", "-")


def listContainsBaseDockerImages(solutionList: list) -> bool:
    """
    Checks if a list of solution contains any solution in the
    BASE_DOCKER_IMAGE_SOLUTION_LIST

    - solutionList: The list to check against the
        BASE_DOCKER_IMAGE_SOLUTION_LIST
    """
    if len([s for s in solutionList
            if s in BASE_DOCKER_IMAGE_SOLUTION_LIST]) > 0:
        return True

    return False
