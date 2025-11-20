#!/bin/bash
# Interactive launcher for Tank Game
# Provides a simple menu interface for building and running the game

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════╗"
echo "║     Tank Game - Interactive Launcher   ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# Main menu
show_menu() {
    echo ""
    echo -e "${CYAN}What would you like to do?${NC}"
    echo ""
    echo "  1) Run iOS (single player)"
    echo "  2) Run iOS (multiplayer - 2 instances)"
    echo "  3) Run macOS"
    echo "  4) Build only (iOS)"
    echo "  5) Build only (macOS)"
    echo "  6) Clean build artifacts"
    echo "  7) Show available simulators"
    echo "  8) Exit"
    echo ""
    echo -n -e "${YELLOW}Enter your choice [1-8]: ${NC}"
}

# Show available simulators
show_simulators() {
    echo ""
    echo -e "${GREEN}Available iOS Simulators:${NC}"
    xcrun simctl list devices available | grep "iPhone" || echo "  No iPhone simulators found"
    echo ""
    echo -e "${GREEN}Available tvOS Simulators:${NC}"
    xcrun simctl list devices available | grep "Apple TV" || echo "  No Apple TV simulators found"
    echo ""
    read -p "Press Enter to continue..."
}

# Execute choice
while true; do
    show_menu
    read choice
    
    case $choice in
        1)
            echo ""
            echo -e "${BLUE}Launching iOS (single player)...${NC}"
            ./run.sh
            break
            ;;
        2)
            echo ""
            echo -e "${BLUE}Launching iOS multiplayer (2 instances)...${NC}"
            ./run.sh -n 2
            break
            ;;
        3)
            echo ""
            echo -e "${BLUE}Launching macOS...${NC}"
            ./run.sh -p macOS
            break
            ;;
        4)
            echo ""
            echo -e "${BLUE}Building iOS...${NC}"
            ./build.sh
            echo ""
            read -p "Press Enter to continue..."
            ;;
        5)
            echo ""
            echo -e "${BLUE}Building macOS...${NC}"
            ./build.sh -p macOS
            echo ""
            read -p "Press Enter to continue..."
            ;;
        6)
            echo ""
            echo -e "${BLUE}Cleaning build artifacts...${NC}"
            make clean
            echo ""
            read -p "Press Enter to continue..."
            ;;
        7)
            show_simulators
            ;;
        8)
            echo ""
            echo -e "${GREEN}Goodbye! 🚀${NC}"
            exit 0
            ;;
        *)
            echo ""
            echo -e "${RED}Invalid choice. Please enter a number between 1 and 8.${NC}"
            sleep 2
            ;;
    esac
    
    clear
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════╗"
    echo "║     Tank Game - Interactive Launcher   ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
done
