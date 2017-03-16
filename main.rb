require_relative 'cpu'
require_relative 'screen'

def main
	cpu = CPU::Emulator.new
	cpu.load_rom("UFO") #load the game
	while true
		cpu.emulate
	end
end
main