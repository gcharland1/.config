from utils import bashUtils


def test_execute_success():
    command = "echo 'Test'"
    expectedResponse = "Test\n"

    actualResponse = bashUtils.execute(command)
    assert actualResponse == expectedResponse


def test_execute_fail():
    command = "this is not a valid command"
    expectedResponse = None

    actualResponse = bashUtils.execute(command)
    assert actualResponse == expectedResponse
