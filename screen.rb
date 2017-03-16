require 'gosu'

class Screen < Gosu::Window
	attr_accessor :sprite_collection, :tile_size, :width, :height, :id
	def initialize(name, width, height, tile_size,chip)
		super width*tile_size, height*tile_size
		self.caption = name
		@chip = chip
		@width = width
		@height = height
		@tile_size = tile_size
		@x = 0
		@y = 0
		@sprite_collection = []
		@@id = 0
		@buffer_check = []
	end

	def run
		#TODO
	end

	def draw
		@sprite_collection.each {|c| c.draw}
	end

	def update
		# TODO
	end

	def draw_pixel(x_pos, y_pos, color)
		# @pixel.warp(x_pos,y_pos)
		# if color == 0
		# 	# @color = @@COLOR[0]
		# 	# @color = Gosu::Color.rgb(117, 117, 117)
		# 	# @color = 0xffff8888
		# 	# @string = 16777215.to_s(16)
		# 	# @string = '%x' % @string.to_i(16)
		# 	# @string.reverse!
		# 	# # puts "here!"
		# 	# bcd_value =  @string.to_s.each_char.each_slice(2).map{|x| x.join}
		# 	# if bcd_value.size == 1
		# 	# 	2.times{bcd_value.push(0.to_s)}
		# 	# elsif bcd_value.size == 2
		# 	# 	bcd_value.push(0.to_s)
		# 	# end
		# 	# bcd_value.reverse!
		# 	# bcd_value.each do |i|
		# 	# puts i.reverse.to_i(16)
		# 	@color = @@COLOR[0]
		# elsif color == 1
		# 	@color = @@COLOR[1]
		# end
		x = x_pos*@tile_size
		y = y_pos*@tile_size
		@sprite_collection.push(Pixel.new(x, y, color, @tile_size))
	end

	def create_buffer_check(buffer)
		@buffer_check = buffer
	end

	def draw_buffer(imagebuffer)
		@sprite_collection.clear
		for y in 0...32
			for x in 0...64
				@sprite_collection.push(Pixel.new(x*@tile_size,y*@tile_size,imagebuffer[x+(y*@width)], @tile_size))
			end
		end
	end

	def button_down(id)
		@@id = id
	end

	def get_pixel(x,y)
		x_pos = x*@tile_size
		y_pos = y*@tile_size
		@sprite_collection.each do |j|
			if j.x == x_pos and j.y == y_pos
				if j.color == 1
					color =  1
				elsif j.color == 0
					color =  0
				end
				return color
			end
		end
	end

	def clear_pixel
		@sprite_collection.clear
	end

	def get_button_down
		@@id
	end

	def clear_button
		@@id = 0
	end
end

class Pixel
	@@COLOR = Hash[1=>Gosu::Color::WHITE, 0=>Gosu::Color::BLACK]
	attr_accessor :x, :y, :color
	def initialize(x,y,color,tile_size)
		@width = @height = 0.0
		@x = x
		@y = y
		@color = color 
		@tile_size = tile_size
	end

	def warp(x,y)
		@x, @y = x, y
	end

	def clear_pixel
		@tile_size = 0
	end

	def draw
		Gosu.draw_rect(@x,@y,@tile_size,@tile_size,@@COLOR[@color])
	end
end

# class SpriteCollection
# 	attr_reader :sprites

# 	def initialize 
# 		@sprites = Hash.new
# 	end

# 	def add(obj)
# 		init_list(obj.class) unless @sprites[obj.class]
# 		@sprites[obj.class].push(obj)
# 	end

# 	def remove(obj)
# 		@sprites[obj.class].delete(obj) if @sprites[obj.class]
# 	end

# 	def init_list(class_name)
# 		@sprites[class_name] = Array.new
# 	end

# 	def update
# 		@sprites.each_value do |list|
# 			list.each {|x| x.update}
# 		end
# 	end

# 	def draw
# 		@sprites.each_value do |list|
# 			list.each {|x| x.draw}
# 		end
# 	end
# end

# Screen.new("CHIP8RBY",64,32,10).show
