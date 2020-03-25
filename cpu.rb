require_relative "screen"

module CPU
	module AUX
		KEY_MAPPINGS = Hash[
				0x0=>Gosu::KB_NUMPAD_0,
				0X1=>Gosu::KB_NUMPAD_1,
				0x2=>Gosu::KB_NUMPAD_2,
				0x3=>Gosu::KB_NUMPAD_3,
				0x4=>Gosu::KB_NUMPAD_4,
				0x5=>Gosu::KB_NUMPAD_5,
				0x6=>Gosu::KB_NUMPAD_6,
				0x7=>Gosu::KB_NUMPAD_7,
				0x8=>Gosu::KB_NUMPAD_8,
				0x9=>Gosu::KB_NUMPAD_9,
				0xA=>Gosu::KB_A,
				0xB=>Gosu::KB_B,
				0xC=>Gosu::KB_C,
				0xD=>Gosu::KB_D,
				0xE=>Gosu::KB_E,
				0xF=>Gosu::KB_F
		]
		FONTS = [
					0xF0, 0x90, 0x90, 0x90, 0xF0, # 0
					0x20, 0x60, 0x20, 0x20, 0x70, # 1
					0xF0, 0x10, 0xF0, 0x80, 0xF0, # 2
					0xF0, 0x10, 0xF0, 0x10, 0xF0, # 3
					0x90, 0x90, 0xF0, 0x10, 0x10, # 4
					0xF0, 0x80, 0xF0, 0x10, 0xF0, # 5
					0xF0, 0x80, 0xF0, 0x90, 0xF0, # 6
					0xF0, 0x10, 0x20, 0x40, 0x40, # 7
					0xF0, 0x90, 0xF0, 0x90, 0xF0, # 8
					0xF0, 0x90, 0xF0, 0x10, 0xF0, # 9
					0xF0, 0x90, 0xF0, 0x90, 0x90, # A
					0xE0, 0x90, 0xE0, 0x90, 0xE0, # B
					0xF0, 0x80, 0x80, 0x80, 0xF0, # C
					0xE0, 0x90, 0x90, 0x90, 0xE0, # D
					0xF0, 0x80, 0xF0, 0x80, 0xF0, # E
					0xF0, 0x80, 0xF0, 0x80, 0x80  # F
				]
	end

	module OPERATION_LIST
		OPERATION = {
			0x0000=>"jump_to_machine_code", # TODO: Need to check on this one 
			0x00E0=>"clear_the_display",
			0x00EE=>"return_from_a_subroutine",
			0x1000=>"jump_to_address",
			0x2000=>"call_subroutine",
			0x3000=>"skip_next_if_value_equal_vx",
			0x4000=>"skip_next_if_value_not_equal_vx",
			0x5000=>"skip_next_if_vx_equal_vy",
			0x6000=>"set_val_into_vx",
			0x7000=>"add_value_to_vx",
			0x8000=>"stores_vy_into_vx",
			0x8001=>"set_vx_or_vy",
			0x8002=>"set_vx_and_vy",
			0x8003=>"set_vx_xor_vy",
			0x8004=>"add_vx_vy",
			0x8005=>"sub_vx_vy",
			0x8006=>"shr_vx",
			0x8007=>"subn_vx_vy",
			0x800E=>"shl_vx",
			0x9000=>"sne_vx_vy",
			0xA000=>"load_index_with_value",
			0xB000=>"jump_to_v0_plus_address",
			0xC000=>"random_byte_and",
			0xD000=>"display_sprites",
			0xE09E=>"skip_next_if_key_is_pressed",
			0xE0A1=>"skip_next_if_key_is_not_pressed",
			0xF007=>"set_value_with_delaytimer",
			0xF00A=>"wait_for_keypress",
			0xF015=>"set_delaytimer_with_value",
			0xF018=>"set_soundtimer_with_value",
			0xF01E=>"add_index_with_value",
			0xF029=>"set_index_with_value",
			0xF033=>"store_bcdvalue_in_memory",
			0xF055=>"store_regs_in_memory",
			0xF065=>"read_regs_from_memory",
		}
	end

	class Emulator
		attr_accessor :imagebuffer
		def initialize
			@memory = Array.new(4096) 
			@screen = Screen.new("CHIP8RBY",64,32,10,self)
			@tile_size = @screen.tile_size
			@timers = Hash['DELAY'=> 0, 'SOUND'=>0]
			@key = Array.new(16){nil}
			@stack = Array.new(16){0}
			@opcode = 0
			@regs = Hash['v'=>Array.new(16){0}, 'INDEX'=>0, 'STACK'=>0x52, 'PC'=>0x200]
			@memory[0...80] = AUX::FONTS
			@imagebuffer = Array.new(64*32){0}
			@drawRequest = false
		end

		def increase_pc
			@regs['PC'] += 2
		end

		def update_timers
			if @timers['DELAY'] > 0 then @timers['DELAY'] -= 1 end
			if @timers['SOUND'] > 0 then if @timers['SOUND'].eql? 1 then p "BEEP!"; @timers['SOUND'] -= 1; end end 
		end
		
		def get_opcode
			@opcode = @memory[@regs['PC']] << 8 | @memory[@regs['PC'] + 1]
		end
		
		def emulate
			get_opcode
			increase_pc

			# Checking if the MSB is 8 or F E 0
			case (@opcode&0xF000)
			when 0x8000
				operation = (@opcode&0xF00F)
			when 0xF000
				operation = (@opcode&0xF0FF)
			when 0xE000
				operation = (@opcode&0xF0FF)
			when 0x0000
				operation = (@opcode&0x00FF)
			else
				operation = (@opcode&0xF000)
			end
                        print("pc :"); print(@regs['PC']); print("\n");
                        print("opcode :"); print(@opcode); print("\n");
                        print("operation: "); print(operation); print("\n");
                        sleep(0.2);

			send(CPU::OPERATION_LIST::OPERATION[operation])
			update_timers
		end

		def jump_to_machine_code
			# TODO: 
		end

		def clear_the_display
			@screen.clear_pixel
		end

		def return_from_a_subroutine
			2.times do |i|
				if i.eql? 0 then @regs['PC'] = (@memory[@regs['STACK'] - (i+1)] << 8)
				else @regs['PC'] += (@memory[@regs['STACK'] - (i+1)]) end
			end
			@regs['STACK'] -= 2
		end

		def jump_to_address
			@regs['PC'] = (@opcode&0x0FFF)
		end

		def call_subroutine
			2.times do |i|
				if i.eql? 0 then @memory[@regs['STACK'] + i] = (@regs['PC']&0x00FF)
				else @memory[@regs['STACK'] + i] = (@regs['PC']&0xFF00) >> 8 end
			end
			@regs['STACK'] += 2
			@regs['PC'] = (@opcode&0x0FFF)
		end

		def skip_next_if_value_equal_vx
			if @regs['v'][(@opcode&0x0F00)>>8].eql? (@opcode & 0x00FF) then increase_pc end
		end

		def skip_next_if_value_not_equal_vx
			unless @regs['v'][(@opcode&0x0F00)>>8].eql? (@opcode & 0x00FF) then increase_pc end
		end

		def skip_next_if_vx_equal_vy
			if @regs['v'][(@opcode&0x0F00)>>8].eql? @regs['v'][(@opcode&0x00F0)>>4] then increase_pc end
		end

		def set_val_into_vx
			@regs['v'][(@opcode&0x0F00)>>8] = (@opcode&0x00FF)
		end

		def add_value_to_vx
			temp = @regs['v'][(@opcode&0x0F00)>>8] + (@opcode & 0x00FF)
			@regs['v'][(@opcode&0x0F00)>>8] = if temp < 0x100 then temp else temp - 0x100 end
		end

		def stores_vy_into_vx
			@regs['v'][(@opcode&0x0F00)>>8] = @regs['v'][(@opcode&0x00F0)>>4]
		end

		def set_vx_or_vy
			@regs['v'][(@opcode&0x0F00)>>8] |= @regs['v'][(@opcode&0x00F0)>>4]
		end

		def set_vx_and_vy
			@regs['v'][(@opcode&0x0F00)>>8] &= @regs['v'][(@opcode&0x00F0)>>4]
		end

		def set_vx_xor_vy
			@regs['v'][(@opcode&0x0F00)>>8] ^= @regs['v'][(@opcode&0x00F0)>>4]
		end

		def add_vx_vy
	        temp = @regs['v'][(@opcode & 0x0F00) >> 8] + @regs['v'][(@opcode & 0x00F0) >> 4]
	        if temp > 0xFF
	            @regs['v'][(@opcode & 0x0F00) >> 8] = temp - 0x100
	            @regs['v'][0xF] = 1
	        else
	            @regs['v'][(@opcode & 0x0F00) >> 8] = temp
	            @regs['v'][0xF] = 0
	        end
		end

		def sub_vx_vy
			source_reg = @regs['v'][(@opcode & 0x00F0) >> 4]
			dest_reg = @regs['v'][(@opcode & 0x0F00) >> 8]
			dest_reg -= source_reg
			if dest_reg <= 0 then @regs['v'][0xF] = 1
			else @regs['v'][0xF] = 0; dest_reg += 0xFF end
			@regs['v'][(@opcode&0x0F00)>>8] = dest_reg
		end

		def shr_vx
			@regs['v'][(@opcode & 0x0F00) >> 8] >>= 1 
			@regs['v'][0xF] = (@regs['v'][(@opcode & 0x0F00) >> 8] & 0x1)
		end

		def subn_vx_vy
			source_reg = @regs['v'][(@opcode & 0x00F0) >> 4]
			dest_reg = @regs['v'][(@opcode & 0x0F00) >> 8]
			dest_reg -= (source_reg); dest_reg *= -1
			if dest_reg <= 0 then @regs['v'][0xF] = 1
			else @regs['v'][0xF] = 0; dest_reg += 0x100 end
			@regs['v'][(@opcode&0x0F00)>>8] = dest_reg
		end

		def shl_vx
			@regs['v'][(@opcode&0x0F00) >> 8] <<= 1
			@regs['v'][0xF] = (@regs['v'][(@opcode&0x0F00) >> 8]&0x80) >> 8
		end

		def sne_vx_vy
			if @regs['v'][(@opcode&0x0F00) >> 8] != @regs['v'][(@opcode&0x00F0) >> 4]
				increase_pc
			end
		end

		def load_index_with_value
			@regs['INDEX'] = (@opcode&0x0FFF)
		end

		def jump_to_v0_plus_address
			@regs['PC'] = @regs['INDEX'] + (@opcode & 0x0FFF)
		end

		def random_byte_and
			@regs['v'][(@opcode & 0x0F00) >> 8] = (@opcode & 0x00FF) & Random.rand(0xFF)
		end

		def display_sprites
			x_pos = @regs['v'][(@opcode&0x0F00) >> 8]
			y_pos = @regs['v'][(@opcode&0x00F0) >> 4]
			height = (@opcode & 0x000F)
			@regs['v'][0xF] = 0
			for y in 0...height
				pixel = @memory[@regs['INDEX']+y]
				for x in 0...8
					if (pixel&(0x80>>x)) != 0
						if(@imagebuffer[x_pos+x + ((y_pos+y) * @screen.width)] == 1)
							@regs['v'][0xF] = 1
						end
						@imagebuffer[x_pos+x + ((y_pos+y) * @screen.width)] ^= 1
					end
				end
			end
			@screen.draw_buffer(@imagebuffer)
			@screen.tick
		end

		def skip_next_if_key_is_pressed
			key = @screen.get_button_down
			if key.eql? AUX::KEY_MAPPINGS[@regs['v'][(@opcode&0x0F00) >> 8]] then  increase_pc end
		end

		def skip_next_if_key_is_not_pressed
			key = @screen.get_button_down
			if not key == AUX::KEY_MAPPINGS[@regs['v'][(@opcode&0x0F00) >> 8]] then  increase_pc end
		end

		def set_value_with_delaytimer
			@regs['v'][(@opcode & 0x0F00) >> 8] = @timers['DELAY']
		end

		def wait_for_keypress
			val = (@opcode &0x0F00) >> 8
			# TODO: in the future
		end

		def set_delaytimer_with_value
			@timers['DELAY'] = @regs['v'][(@opcode & 0x0F00) >> 8]
		end

		def set_soundtimer_with_value
			@timers['SOUND'] = @regs['v'][(@opcode & 0x0F00) >> 8]
		end

		def add_index_with_value
			@regs['INDEX'] += @regs['v'][(@opcode & 0x0F00) >> 8]
		end

		def set_index_with_value
			@regs['INDEX'] = @regs['v'][(@opcode & 0x0F00) >> 8] * 5
		end

		def store_bcdvalue_in_memory
			bcd_value = "%03d" % (@regs['v'][(@opcode & 0x0F00) >> 8])
			3.times do |i|
				@memory[@regs['INDEX'] + i] = Integer(bcd_value[i])
			end
		end

		def store_regs_in_memory
			for counter in 0..((@opcode & 0x0F00) >> 8)
				@memory[@regs['INDEX'] + counter] = @regs['v'][counter]
			end
		end

		def read_regs_from_memory
			for counter in 0..((@opcode & 0x0F00) >> 8)
				@regs['v'][counter] = @memory[@regs['INDEX'] + counter]
			end
		end

		def check_program_size(program)
			if program.size > 4096 - 0x200 then raise 'ROM exceeds memory size!' end
		end

		def load_rom(filename)
			check_program_size(IO.binread(filename))
			File.open(filename, "rb") do |file|
				for i in 0...file.size
					buffer = file.read(1).unpack('C')[0]
					@memory[0x200+i] = buffer
				end
			end
		end
	end
end

