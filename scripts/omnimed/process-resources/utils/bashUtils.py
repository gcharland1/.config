import subprocess


def execute(command: str, onError=None) -> str:
    """
    Executes the given command.
    If an error occurs, return the provided onError value
    """
    try:
        result = subprocess.run(command, shell=True, check=True, text=True,
                                capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e.stderr}")
        return onError
