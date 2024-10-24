import curses
import re

from utils import dockerUtils, gitUtils, mavenUtils, solutionUtils

from resources.cliConstants import CLI_DELIMITER, CLI_HEADER, CLI_MENU_NAV, \
        CLI_MENU_PR, CLI_MENU_REPORT, CLI_PROGRESS_BLOCK


class ProcessRessources():
    """
    Textual context to manage Omnimed-Solutions process Ressources
    """

    cursor = 0  # The cursor position used to select solutions
    dependencyMap = {}  # The map of each solution and their dependencies
    dirtySolutionList = []  # The list of solutions modified locally
    filter = ""  # The solution filter string
    modifiedSolutionList = []  # The list of solutions modified in the branch
    listLength = 30  # The length of the list to display
    previousSelection = []  # Copy of the selected solutions if the user
    # wants to undo "select all"

    selectedSolutions = []  # Currently selected solutions list
    selectedSolutionsWithNoDiff = []  # Selected solutions that are not
    # modified in the current branch (Used for display purposes)

    unselectedSolutions = []  # All the solutions not selected by the user

    def __init__(self, screen: curses.window, debug: bool = False) -> None:
        # Window setup
        self.screen = screen
        self.screen.nodelay(1)
        self.terminalHeight, _ = self.screen.getmaxyx()

        self.mavenHandler = mavenUtils.MavenHandler(debug)

        # Show the user the diff with fix-develop
        self.modifiedSolutionList = gitUtils.getModifiedSolutionList()

        # Add local modifications to the list
        self.dirtySolutionList = gitUtils.getLocalModificationList()
        [self.modifiedSolutionList.append(solution)
         for solution in self.dirtySolutionList
         if solution not in self.modifiedSolutionList]

        # Pre-select modified solutionList
        self.selectedSolutions = self.modifiedSolutionList

        # Solution list setup
        self.completeSolutionList = solutionUtils.getSolutionList(sort=True)
        self.filterUnselectedSolutions()
        self.state = 0

    def compileSelectedSolutions(self) -> None:
        """ Initiate process ressource with selected solution list """

        self.mavenHandler.setSubprocessMap({})
        self.mavenHandler.setSolutionMap(
                solutionUtils.removeUnchangedSolutionsFromMap(
                    solutionUtils.generateDependencyMap(
                        self.selectedSolutions)
                    )
                )

        self.mavenHandler.mavenCleanInstallSolutionMap(
                printFunction=self.compose)

        if dockerUtils.listContainsBaseDockerImages(
                self.mavenHandler.getSolutionMap()):
            dockerUtils.buildBaseDockerImages()

        self.state = 2
        self.updateCommitForCompiledSolutions()

        # Clean the mavenHandler after compiling
        self.mavenHandler.setSolutionMap({})

        # Clean selected solution list
        self.selectedSolutions = self.modifiedSolutionList

    def compose(self) -> None:
        """ Prints the cli on screen """

        self.screen.clear()
        self.safePrint(CLI_HEADER)
        self.safePrint(CLI_DELIMITER)
        if self.state == 0:
            self.safePrint(CLI_MENU_NAV)
            self.safePrint(CLI_DELIMITER)
            self.printApplication()
        elif self.state == 1:
            self.safePrint(CLI_MENU_PR)
            self.safePrint(CLI_DELIMITER)
            self.updateProgress()
        elif self.state == 2:
            self.safePrint(CLI_MENU_REPORT)
            self.safePrint(CLI_DELIMITER)
            self.printProcessRessourceOutput()

        self.screen.refresh()

    def filterUnselectedSolutions(self) -> None:
        """
        Filters solution list to remove selected solutions
        and match the current filter
        """

        self.selectedSolutions = sorted(self.selectedSolutions)
        self.selectedSolutionsWithNoDiff = [solution
                                            for solution
                                            in self.selectedSolutions
                                            if solution
                                            not in self.modifiedSolutionList]

        self.unselectedSolutions = [solution
                                    for solution
                                    in self.completeSolutionList
                                    if solution
                                    not in self.selectedSolutions
                                    and solution
                                    not in self.modifiedSolutionList]

        # Filter the remaining solutions if the filter is at least 3 char long
        if len(self.filter) >= 3:
            matcher = re.compile(f".*{self.filter}.*")
            self.unselectedSolutions = [solution for solution
                                        in self.unselectedSolutions
                                        if matcher.match(solution)]

        self.listLength = max(0, min(self.terminalHeight - 1,
                                     len(self.modifiedSolutionList) +
                                     len(self.selectedSolutionsWithNoDiff) +
                                     len(self.unselectedSolutions)
                                     ) - 1)

        self.cursor = min(self.cursor, self.listLength)

    def formatSolutionStr(self, solutionName: str,
                          solutionPositionInDisplay: int) -> str:
        """
        Formats the provided solutonName in the following format
          |   [*] selected-solution
          |   [ ] unselected-solution
          | > [ ] solution-under-the-cursor

        - solutionName: the name of the solution to format
        - solutionPositionInDisplay: the index of the solution
            in the displayed list
        """

        cursor = ">" if self.cursor == solutionPositionInDisplay else " "
        selected = "*" if solutionName in self.selectedSolutions else " "
        return f" {cursor}[{selected}] {solutionName}\n"

    def handleInput(self, key: int) -> None:
        """
        Handles the keyboard input to control the cli

        - key: the key pressed by the user
        """

        if key == 1:  # Ctrl+A to select all solutions
            self.selectAllSolutions()
        elif key == 8:  # Ctrl+Backspace to clear filter
            self.filter = ""
        elif key == 9:  # Tab to clear filter
            self.toggleMenu()
        elif key == 10:  # Enter to launch ProcessRessources
            if self.state == 0:
                self.state = 1
                self.compileSelectedSolutions()
            elif self.state == 2:
                self.state = 0
        elif key == 32:  # Space to select
            self.selectSolution()
        elif key == 258:  # Arrow down
            self.cursor = min(self.cursor + 1, self.listLength)
        elif key == 259:  # Arrow up
            self.cursor = max(self.cursor - 1, 0)
        elif key == 263:  # Backspace to delete filter
            self.filter = self.filter[:-1]
        else:
            self.filter += chr(key)

    def printApplication(self) -> None:
        """
        Prints the application in this order:
            - The list of modified solutions in the branch (if applicable)
            - The list of selected solutions that are not
                modified in the current branch (if applicable)
            - A textual searchbar to filter the solutions
            - The list of all other solutions that respect the filter written
                in the searchbar.
        """

        solutionIndex = 0
        if len(self.modifiedSolutionList) > 0:
            self.safePrint(
                    " ------- [ Différences avec fix-develop ] ---------\n")
            for diff in self.modifiedSolutionList:
                self.safePrint(self.formatSolutionStr(diff, solutionIndex))
                solutionIndex += 1

        if len(self.selectedSolutionsWithNoDiff) > 0:
            self.safePrint(
                    "\n ------- [ Autres solutions à compiler ] ----------\n")
            if len(self.selectedSolutions) == len(self.completeSolutionList):
                self.safePrint(
                    "\n !!!! Toutes les solutions sont sélectionnées  !!!!\n")
            else:
                for solution in self.selectedSolutionsWithNoDiff:
                    self.safePrint(
                            self.formatSolutionStr(solution, solutionIndex))
                    solutionIndex += 1

        filter = self.filter if self.filter != "" else "Rechercher ..."
        self.safePrint(f"\n ------- [ {filter:<30} ] -------\n")

        i = 0
        while i < len(self.unselectedSolutions):
            solution = self.unselectedSolutions[i]
            if not self.safePrint(
                    self.formatSolutionStr(solution, solutionIndex)):
                break

            solutionIndex += 1
            i += 1

    def printProcessRessourceOutput(self):
        """
        Prints the report of the finished process resources
        """
        self.safePrint(" #### Process Ressources Terminé ####\n")
        failedSolutionList = [solution for solution, subprocess
                              in self.mavenHandler.getSubprocessMap().items()
                              if subprocess is not None
                              and subprocess.poll() != 0]

        nError = len(failedSolutionList)
        nError = nError if nError > 0 else "Aucune"
        self.safePrint(
                f" -------------[ {nError:^6} erreur(s) ]---------------\n")
        [self.safePrint(f" - {s}\n") for s in failedSolutionList]

        self.safePrint(
            "\n ------------[ Solutions compilées ]-------------\n")
        [self.safePrint(f" - {solution}\n")
         for solution in self.mavenHandler.getSubprocessMap().keys()]

        self.safePrint("\n\n Rapports de compilation:\n" +
                       "\t~/git/Omnimed-solutions/<sol>/" +
                       "processRessources.log\n")

        self.screen.refresh()

    def run(self):
        """
        Runs the CLI. Wait for keypress and respond accordingly.
        """
        self.compose()
        while 1:
            key = self.screen.getch()
            if type(key) is int and key >= 0:
                if key == 27:  # Escape to exit
                    break
                else:
                    self.handleInput(key)
                    self.filterUnselectedSolutions()
                    self.compose()

    def safePrint(self, string: str) -> bool:
        """
        Prints the provided string without overflowing the screen

        - string: the string to print
        """
        y, _ = self.screen.getyx()

        # Prevent overflow of text on screen
        if self.terminalHeight <= y + len(string.split('\n')):
            return False

        try:
            self.screen.addstr(string)
            return True
        except curses.error:
            pass

    def selectAllSolutions(self) -> None:
        """
        Toggles between selecting all the solutions and the previously
        selected solution list
        """

        if len(self.selectedSolutions) < len(self.completeSolutionList):
            self.previousSelection = self.selectedSolutions
            self.selectedSolutions = self.completeSolutionList
        else:
            self.selectedSolutions = self.previousSelection

        self.filterUnselectedSolutions()

    def selectSolution(self) -> None:
        """
        Push or pop the solution under the cursor to the selected solution list
        """

        currentSolution = self.getSolutionUnderCursor()
        if (currentSolution in self.selectedSolutions):
            self.selectedSolutions.remove(currentSolution)
        else:
            self.selectedSolutions.append(currentSolution)

    def getSolutionUnderCursor(self) -> str:
        """
        Returns the solution name under the cursor
        """
        cursor = self.cursor

        # If the cursor in in the modified solution section
        if (cursor < len(self.modifiedSolutionList)):
            return self.modifiedSolutionList[cursor]

        cursor = cursor - len(self.modifiedSolutionList)
        # If the cursor in in the selected solution section
        if (cursor < len(self.selectedSolutionsWithNoDiff)):
            return self.selectedSolutionsWithNoDiff[cursor]

        cursor = cursor - len(self.selectedSolutionsWithNoDiff)
        # If the cursor in in the other solutions section
        return self.unselectedSolutions[cursor]

    def toggleMenu(self) -> None:
        """
        Jumps the cursor to the first row of the next section
        """
        cursor = self.cursor
        if cursor < len(self.modifiedSolutionList):
            self.cursor = len(self.modifiedSolutionList)
        else:
            cursor = cursor - len(self.modifiedSolutionList)
            if cursor < len(self.selectedSolutionsWithNoDiff):
                self.cursor = len(self.selectedSolutionsWithNoDiff) + \
                                  len(self.modifiedSolutionList)
            else:
                self.cursor = 0

    def updateCommitForCompiledSolutions(self) -> None:
        """
        Save the current sha1.sum file for all successfully compied solutions
        """
        compiledSolutionList = [solution
                                for solution, subprocess
                                in self.mavenHandler.getSubprocessMap().items()
                                if subprocess is not None
                                and subprocess.poll() == 0]

        [gitUtils.getLastCommitHashForSolution(
                solution=solution,
                saveToFile=True)
         for solution in compiledSolutionList]

    def updateProgress(self) -> None:
        """
        Print the CLI_PROGRESS_BLOCK formatted with the current compilation
        status
        """
        numberOfSolutions = len(self.mavenHandler.getSolutionMap().keys())
        self.safePrint(f"\n Compilation des {numberOfSolutions} " +
                       "ressources nécessaires à\n")
        [self.safePrint(f" - {solution}\n")
         for solution in self.selectedSolutions]

        compiledSolutionList = [solution for solution, subprocess
                                in self.mavenHandler.getSubprocessMap().items()
                                if subprocess is not None
                                and subprocess.poll() is not None]
        done = len(compiledSolutionList)
        inProgressSolutionList = [solution for solution, subprocess
                                  in
                                  self.mavenHandler.getSubprocessMap().items()
                                  if subprocess is not None
                                  and subprocess.poll() is not None]

        prog = len(inProgressSolutionList)
        waitingSolutionList = [solution for solution
                               in self.mavenHandler.getSolutionMap().keys()
                               if solution not in
                               self.mavenHandler.getSubprocessMap().keys()]
        wait = len(waitingSolutionList)

        self.safePrint(CLI_PROGRESS_BLOCK.format(done=done,
                                                 prog=prog,
                                                 wait=wait))

        self.safePrint("\nSolutions en attente:\n")
        [self.safePrint(f" - {solution} - " +
                        f"{self.mavenHandler.getSolutionMap()[solution]}\n")
         for solution in waitingSolutionList]

        self.safePrint("\nSolutions en cours de compilation:\n")
        [self.safePrint(f" - {solution}\n")
         for solution in inProgressSolutionList]

        self.safePrint("\nSolutions compilées:\n")
        [self.safePrint(f" - {soluton}\n") for soluton in compiledSolutionList]


def main(stdscr) -> None:
    """
    Initiates the ProcessRessources class with the provided stdscr
    """

    _debug = False

    app = ProcessRessources(stdscr, _debug)
    app.run()


curses.initscr()
curses.wrapper(main)
