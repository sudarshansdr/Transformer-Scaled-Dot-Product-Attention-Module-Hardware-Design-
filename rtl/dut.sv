//---------------------------------------------------------------------------
// DUT - 564/464 Project
//---------------------------------------------------------------------------
`include "common.vh"

module MyDesign(
//---------------------------------------------------------------------------
//System signals
  input wire reset_n                      ,  
  input wire clk                          ,

//---------------------------------------------------------------------------
//Control signals
  input wire dut_valid                    , 
  output reg dut_ready                   ,

//---------------------------------------------------------------------------
//input SRAM interface
  output reg                           dut__tb__sram_input_write_enable  ,
  output reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_input_write_address ,
  output reg [`SRAM_DATA_RANGE     ]   dut__tb__sram_input_write_data    ,
  output reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_input_read_address  , 
  input  wire [`SRAM_DATA_RANGE     ]   tb__dut__sram_input_read_data     ,     

//weight SRAM interface
  output reg                           dut__tb__sram_weight_write_enable  ,
  output reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_weight_write_address ,
  output reg [`SRAM_DATA_RANGE     ]   dut__tb__sram_weight_write_data    ,
  output reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_weight_read_address  , 
  input  wire [`SRAM_DATA_RANGE     ]   tb__dut__sram_weight_read_data     ,     

//result SRAM interface
  output reg                           dut__tb__sram_result_write_enable  ,
  output reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_result_write_address ,
  output reg [`SRAM_DATA_RANGE     ]   dut__tb__sram_result_write_data    ,
  output reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_result_read_address  , 
  input  wire [`SRAM_DATA_RANGE     ]   tb__dut__sram_result_read_data     ,     

//scratchpad SRAM interface
  output reg                           dut__tb__sram_scratchpad_write_enable  ,
  output reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_scratchpad_write_address ,
  output reg [`SRAM_DATA_RANGE     ]   dut__tb__sram_scratchpad_write_data    ,
  output reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_scratchpad_read_address  , 
  input  wire [`SRAM_DATA_RANGE     ]   tb__dut__sram_scratchpad_read_data  

);

	//Parameters
	localparam Init  = 3'b000;
	localparam s0  = 3'b001;
	localparam s1  = 3'b010;
	localparam s2  = 3'b011;
	localparam s3  = 3'b100;
	localparam s4  = 3'b101;
	localparam s5  = 3'b110;
	localparam s6  = 3'b111;
	localparam s7  = 4'b1000;
	localparam s8  = 4'b1001;
	localparam s9  = 4'b1010;
	localparam s10  = 4'b1011;
	localparam s11  = 4'b1100;
	localparam s12  = 4'b1101;
	localparam s13  = 4'b1110;
	localparam s14  = 4'b1111;
	localparam s15  = 5'b10000;
	localparam s16  = 5'b10001;
	localparam s17  = 5'b10011;
	localparam s18  = 5'b10111;
	
	
	//Reg declaration
	reg [31:0]		ASize;	//Count of data to be read from SRAM 
  	reg [31:0]		BSize;	//Count of data to be read from SRAM 
  	reg [11:0]		A_addr;		//Value of A
	reg [11:0]		B_addr;		//Value of B
  	reg [11:0]		Write_addr;
	reg [31:0]		Accumulator;	//Accumulator
  	reg [7:0]		Aindex;		//Value of A
	reg [7:0]		Bindex;
	reg [7:0]		Count;		//Value of B
	reg [7:0]		CountMatrix;
	reg [4:0]		current_state;	//FSM current state
	reg [4:0]		next_state;	//FSM next state
	reg [11:0]		V_addr;
	reg [11:0]		R_addr;
	reg [7:0]		V_RowCount;
	reg [7:0]		V_CurrentRow;
	reg [31:0]		VSize;	
	reg [7:0]		R_Count;
	reg [7:0]		V_TotalCount;

	reg 			size_count_sel;
  	reg [1:0]		size_count_sel2;
	reg [1:0]		Aread_addr_sel;
  	reg [1:0]		A_index_sel;
	reg [1:0]		B_index_sel;	
  	reg [1:0]		Bread_addr_sel;	
  	reg [1:0]		Count_sel;
	reg [1:0]		MatrixCount_sel;
	reg 			Accumulate_sel;	
  	reg 			Write_enable;
  	reg [1:0]		Write_Address_sel;
	reg 			Calculate_S;
	reg 			Calculate_V;
	reg [3:0]		S_Count;
	reg [3:0]		B_Count;
	reg [1:0]		Vread_addr_sel;
	reg [1:0]		Rread_addr_sel;
	reg [1:0]		V_RowCount_sel;
	reg [1:0]		V_TotalCount_sel;
	reg [1:0]		V_CurrentRow_sel;
	reg [1:0]		VSize_sel;
	reg [1:0]		R_Count_sel;


	//--------------code start--------------//
	
	//Control Path
	
  
  reg [31:0] mac_result_z;       // Output from DW_fp_mac for MAC result
  reg [31:0] accum_result;       // Accumulator result for matrix addition
  
  assign accum_result = Accumulator;

always @(*) begin
		if (Calculate_S == 1'b0)
		begin
			// Used Input and weight SRAM to read matrices values for KQV calculation
		dut__tb__sram_result_read_address <= 1'b0;
		dut__tb__sram_input_write_enable <= 1'b0;
		dut__tb__sram_input_read_address <= A_addr;
		dut__tb__sram_weight_write_enable <= 1'b0;
		dut__tb__sram_weight_read_address <= B_addr;
		dut__tb__sram_result_write_enable <= Write_enable;
		dut__tb__sram_result_write_address <= Write_addr;
		mac_result_z <= (tb__dut__sram_input_read_data * tb__dut__sram_weight_read_data)+ accum_result;
		dut__tb__sram_result_write_data <= mac_result_z;
		dut__tb__sram_scratchpad_write_enable <= Write_enable;
		dut__tb__sram_scratchpad_write_address <= Write_addr+1'b1;
		dut__tb__sram_scratchpad_write_data <= mac_result_z;
		dut__tb__sram_scratchpad_read_address <=0;
		mac_result_z <= (tb__dut__sram_input_read_data * tb__dut__sram_weight_read_data)+ accum_result;
		// the values are written in result and scratchpad SRAMS for future use of Score and attention matrices calculation
		S_Count = 1'b0;
		end
		else if (Calculate_S == 1'b1)
		begin
			// used Scratchpad and result SRAMS to get the values of KQV and are used to calculate Score and attention matrices
		dut__tb__sram_input_write_enable <= 1'b0;
		dut__tb__sram_input_read_address <= 1'b0;
		dut__tb__sram_weight_write_enable <= 1'b0;
		dut__tb__sram_weight_read_address <= 1'b0;
		dut__tb__sram_scratchpad_write_data <= 1'b0;
		dut__tb__sram_scratchpad_write_enable <= 1'b0;
		dut__tb__sram_scratchpad_write_address <= 1'b0;
		if (Calculate_V == 1'b0)
		begin
		dut__tb__sram_result_write_enable <= Write_enable;
		dut__tb__sram_result_write_address <= Write_addr;
		mac_result_z <= (tb__dut__sram_scratchpad_read_data * tb__dut__sram_result_read_data)+ accum_result;
		dut__tb__sram_result_write_data <= mac_result_z;
		dut__tb__sram_result_read_address <= B_addr;
		dut__tb__sram_scratchpad_write_enable <= 1'b0;
		dut__tb__sram_scratchpad_read_address <= A_addr;
		end
		else
		begin
		dut__tb__sram_result_write_enable <= Write_enable;
		dut__tb__sram_result_write_address <= Write_addr;
		mac_result_z <= (tb__dut__sram_scratchpad_read_data * tb__dut__sram_result_read_data)+ accum_result;
		dut__tb__sram_result_write_data <= mac_result_z;
		dut__tb__sram_result_read_address <= R_addr;
		dut__tb__sram_scratchpad_write_enable <= 1'b0;
		dut__tb__sram_scratchpad_read_address <= V_addr;
		end
		S_Count = 1'b1;	
		end
end

  reg compute_complete;
  reg dut_ready_r;
    
  always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    dut_ready_r <= 1'b1; // Initialize dut_ready to high when reset is active
  end else if (dut_valid) begin
    dut_ready_r <= 1'b0; // Set dut_ready low when dut_valid goes high
  end else if (compute_complete) begin
    dut_ready_r <= 1'b1; // Set dut_ready high when computation completes	
  end
end

  assign dut_ready = dut_ready_r; // send it to test fixture

	//FSM
	always @(posedge clk or negedge reset_n) begin
	if (!reset_n)
      begin
        current_state <= 4'b0;  
		//if reset always state comes to Init    
      end
	else
		current_state <= next_state;
	end
  
	always @(*) begin
		casex (current_state)

		Init : begin // All control signals are set to default values
			VSize_sel = 2'b00; 
			R_Count_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			V_CurrentRow_sel = 2'b00;
			V_RowCount_sel = 2'b00;
			size_count_sel 	= 1'b0;
			size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b11;
			Vread_addr_sel 	= 2'b11;
			Rread_addr_sel = 2'b11;
			A_index_sel 	= 2'b00;
			Bread_addr_sel 		= 2'b11;
			Count_sel = 2'b00;
			Accumulate_sel 	= 1'b0;
			Write_enable 	= 1'b0;
			Write_Address_sel = 2'b00;
			MatrixCount_sel = 2'b00;
			Calculate_S = 1'b0;
			Calculate_V = 1'b0;
			compute_complete = 1'b0;
			if (dut_valid == 1'b1)
					next_state = s0;
				else
					next_state = Init;			
		end
      	s0 : begin
			VSize_sel = 2'b00;
			R_Count_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			Rread_addr_sel = 2'b11;
			V_CurrentRow_sel = 2'b00;
			V_RowCount_sel = 2'b00;
			size_count_sel 	= 1'b1;
			Vread_addr_sel 	= 2'b11;
			size_count_sel2 = 2'b01;
			Aread_addr_sel 	= 2'b11;
			A_index_sel 	= 2'b11;
			Bread_addr_sel 		= 2'b11;
			Count_sel = 2'b00;
			Accumulate_sel 	= 1'b0;
			Write_enable 	= 1'b0;
			Write_Address_sel = 2'b00;
			MatrixCount_sel = 2'b00;
			Calculate_S = 1'b0;
			Calculate_V = 1'b0;
			compute_complete = 1'b0;
			next_state = s1;
		end
      	s1 : begin
			size_count_sel 	= 1'b0;
			R_Count_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			V_CurrentRow_sel = 2'b00;
			VSize_sel = 2'b10;
			V_RowCount_sel = 2'b00;
			Rread_addr_sel = 2'b11;
			Vread_addr_sel 	= 2'b11;
			size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b00;
			A_index_sel 	= 2'b01;
			Bread_addr_sel 		= 2'b00;
			Count_sel = 2'b10;
			Accumulate_sel 	= 1'b0;
			Write_enable 	= 1'b0;
			Write_Address_sel = 2'b10;
			MatrixCount_sel = 2'b00;
			Calculate_S = 1'b0;
			Calculate_V = 1'b0;
			compute_complete = 1'b0;
			next_state = s10;
		end

		s11 : begin
			size_count_sel      = 1'b0;
			R_Count_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			V_CurrentRow_sel = 2'b00;
			Rread_addr_sel = 2'b11;
			VSize_sel           = 2'b10;
			V_RowCount_sel = 2'b00;
			Vread_addr_sel      = 2'b11;
			size_count_sel2     = 2'b00;
			Aread_addr_sel      = 2'b01;
			A_index_sel         = 2'b01;
			Bread_addr_sel      = 2'b01;
			Count_sel           = 2'b10;
			Accumulate_sel      = (BSize[31:16] == 16'b10);
			Write_enable        = 1'b0;
			Write_Address_sel   = 2'b10;
			MatrixCount_sel     = 2'b11;
			Calculate_V         = 1'b0;
			compute_complete    = 1'b0;
			if (Aindex == ASize[15:0] - 1 && (B_addr + 2) % (BSize[15:0] * BSize[31:16]) != 0)
				next_state = s3;
			else if ((B_addr + 2) % (BSize[15:0] * BSize[31:16]) == 0)
				next_state = s5;
			else if (BSize[31:16] == 16'b10 && BSize[15:0] == 16'b1000) begin
				next_state = s2;
				Write_enable        = 1'b1;
				Write_Address_sel   = 2'b01;
				Accumulate_sel      = 1'b0;
			end else
				next_state = s2;
			if (S_Count == 0)
				Calculate_S = 1'b0;
			else begin
				Calculate_S = 1'b1;
				if ((B_addr + 3) % (BSize[15:0] * BSize[31:16]) == 0)
					Accumulate_sel = (BSize[31:16] == 16'b10);
			end
		end

			s10 : begin
				size_count_sel      = 1'b0;
				R_Count_sel = 2'b00;
				Rread_addr_sel = 2'b11;
				V_CurrentRow_sel = 2'b00;
				VSize_sel           = 2'b10;
				V_TotalCount_sel = 2'b00;
				V_RowCount_sel = 2'b00;
				Vread_addr_sel      = 2'b11;
				size_count_sel2     = 2'b00;
				Aread_addr_sel      = 2'b01;
				A_index_sel         = 2'b01;
				Bread_addr_sel      = 2'b01;
				Count_sel           = 2'b10;
				Accumulate_sel      = 1'b0;
				Write_enable        = 1'b0;
				Write_Address_sel   = 2'b10;
				MatrixCount_sel     = 2'b11;
				Calculate_S         = (S_Count != 0);
				Calculate_V         = 1'b0;
				compute_complete    = 1'b0;
				next_state          = s2;
			end

		s2 : begin
			size_count_sel      = 1'b0;
			R_Count_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			Rread_addr_sel = 2'b11;
			V_CurrentRow_sel = 2'b00;
			V_RowCount_sel = 2'b00;
			Vread_addr_sel      = 2'b11;
			VSize_sel           = 2'b10;
			size_count_sel2     = 2'b00;
			Aread_addr_sel      = (BSize[31:16] == 16'b10 && BSize[15:0] == 16'b10) ? 2'b00 : 2'b01;
			A_index_sel         = 2'b01;
			Bread_addr_sel      = 2'b01;
			Count_sel           = 2'b10;
			Accumulate_sel      = 1'b1;
			Write_enable        = 1'b0;
			Write_Address_sel   = 2'b10;
			MatrixCount_sel     = 2'b11;
			Calculate_V         = 1'b0;
			compute_complete    = 1'b0;

			if (Aindex == ASize[15:0] - 1 && (B_addr + 2) % (BSize[15:0] * BSize[31:16]) != 0) begin
				next_state = s3;
				//If A col is done and only one row of B multiplication is done
			end else if ((B_addr + 2) % (BSize[15:0] * BSize[31:16]) == 0) begin
				next_state = s5;
				//If A col multiplication is done for all the rows in the B matrix
				if (BSize[31:16] == 16'b10 && BSize[15:0] == 16'b10)
					Accumulate_sel = 1'b1;
			end else if (BSize[31:16] == 16'b10 && BSize[15:0] == 16'b1000) begin
				Aread_addr_sel  = 2'b00;
				next_state      = s11;
			end else begin
				next_state = s2;
				//If A column values are not yet done, it rotates in the same state
			end

			if (S_Count == 0) begin
				Calculate_S = 1'b0;
			end else begin
				Calculate_S = 1'b1;
				if ((B_addr + 3) % (BSize[15:0] * BSize[31:16]) == 0) begin
					next_state = s5;
					if (BSize[31:16] == 16'b10 && BSize[15:0] == 16'b10)
						Accumulate_sel = 1'b1;
				end
			end
		end


		s3 : begin
			size_count_sel 	= 1'b0;
			R_Count_sel = 2'b00;
			V_RowCount_sel = 2'b00;
			V_CurrentRow_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			VSize_sel = 2'b10;
			Vread_addr_sel 	= 2'b11;
			Rread_addr_sel = 2'b11;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b00;
        	A_index_sel 	= 2'b00;
        	Bread_addr_sel 		= 2'b01;
        	Count_sel = 2'b10;
			Accumulate_sel 	= 1'b1;
        	Write_enable 	= 1'b0;
        	Write_Address_sel = 2'b10;
			MatrixCount_sel = 2'b11;
			Calculate_V = 1'b0;
			compute_complete = 1'b0;
			if ((BSize[31:16] == 16'b10) &&  (BSize[15:0] == 16'b10))
				Accumulate_sel 	= 1'b0;
			if(S_Count==0)
				Calculate_S = 1'b0;
			else
				Calculate_S = 1'b1;
			next_state = s4;
		end
		s4 : begin
			
			size_count_sel 	= 1'b0;
			R_Count_sel = 2'b00;
			VSize_sel = 2'b10;
			V_CurrentRow_sel = 2'b00;
			V_RowCount_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			Vread_addr_sel 	= 2'b11;
			Rread_addr_sel = 2'b11;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b01;
        	A_index_sel 	= 2'b01;
        	Bread_addr_sel 		= 2'b01;
        	Count_sel = 2'b10;
			Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b1;
        	Write_Address_sel = 2'b01;
			MatrixCount_sel = 2'b11;
			Calculate_V = 1'b0;
			compute_complete = 1'b0;
			if(S_Count==0)
				Calculate_S = 1'b0;
			else
				Calculate_S = 1'b1;
			if ((BSize[31:16] == 16'b10) &&  (BSize[15:0] == 16'b10))
			Accumulate_sel 	= 1'b0;
			//after incrementing the B row and again resets the A col, it again goes to the second state

			next_state = s2;
		end
		s5 : begin
				
			size_count_sel 	= 1'b0;
			R_Count_sel = 2'b00;
			V_CurrentRow_sel = 2'b00;
			VSize_sel = 2'b10;
			V_RowCount_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			Vread_addr_sel 	= 2'b11;
			Rread_addr_sel = 2'b11;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b01;
        	A_index_sel 	= 2'b01;
        	Bread_addr_sel 		= 2'b01;
        	Count_sel = 2'b01;
			Accumulate_sel 	= 1'b1;
        	Write_enable 	= 1'b0;
			Calculate_V = 1'b0;
			compute_complete = 1'b0;
			if (BSize[31:16] == 16'b10)
			begin
				Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b1;
			end
        	Write_Address_sel = 2'b10; 
			if( (BSize[31:16] == 16'b10) &&  (BSize[15:0] == 16'b1000))
			Write_Address_sel = 2'b01;
			MatrixCount_sel = 2'b11;
			if(S_Count==0)
				Calculate_S = 1'b0;
			else
				Calculate_S = 1'b1;
			if ((Count + 1) - ((Count + 1) / ASize[31:16]) * ASize[31:16] == 0)
				MatrixCount_sel = 2'b01;
				
			next_state = s6;
		end

		s6 : begin
			size_count_sel 	= 1'b0;
			R_Count_sel = 2'b00;
			VSize_sel = 2'b10;
			V_CurrentRow_sel = 2'b00;
			V_RowCount_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			Vread_addr_sel 	= 2'b11;
			Rread_addr_sel = 2'b11;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b00;
        	A_index_sel 	= 2'b00;
        	Bread_addr_sel 		= 2'b00;
        	Count_sel = 2'b10;
			Accumulate_sel 	= 1'b1;
        	Write_enable 	= 1'b0;
        	Write_Address_sel = 2'b10;
			compute_complete = 1'b0;
			Calculate_V = 1'b0;
			if ((BSize[31:16] == 16'b10) &&  (BSize[15:0] == 16'b10))
			Write_Address_sel = 2'b01;
			MatrixCount_sel = 2'b11;
			if(S_Count==0)
				Calculate_S = 1'b0;
			else
				Calculate_S = 1'b1;
			
				
        	if (ASize[31:16]*3 == Count)
			begin
				Aread_addr_sel 	= 2'b00;
        		A_index_sel 	= 2'b00;
        		Bread_addr_sel 		= 2'b00;
        		Count_sel = 2'b10;
				size_count_sel2 = 2'b11;
				//If KQV matrix multiplication is done, it goes to the Score matrix calculation
				next_state = s8;
			end
			else if(ASize[31:16]*4 == Count)
			begin
			V_TotalCount_sel = 2'b0;
				next_state = s12;
				//if Score matrix calculation is done, it goes for attention matrix calculation
				VSize_sel = 2'b01;
				Bread_addr_sel 		= 2'b11;
				end
			else
				next_state = s4;
				//after incrementing the B row and A col, it again goes to the second state
		end

		s7 : begin
			// This is the complete state, Whenever this state is arrived, it sets the dut ready to high and goes to the init state.
			size_count_sel 	= 1'b0;
			R_Count_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			VSize_sel = 2'b10;
			Vread_addr_sel 	= 2'b11;
			V_CurrentRow_sel = 2'b00;
			V_RowCount_sel = 2'b00;
			Rread_addr_sel = 2'b11;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b00;
        	A_index_sel 	= 2'b00;
        	Bread_addr_sel 		= 2'b00;
        	Count_sel = 2'b00;
			Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b1;
			if (ASize[31:16] == 1'b1 || ASize[15:0]==1'b1)
			Write_enable 	= 1'b0;

			Calculate_V = 1'b0;
			
        	Write_Address_sel = 2'b10;
			MatrixCount_sel = 2'b11;
			if(S_Count==0)
				Calculate_S = 1'b0;
			else
				Calculate_S = 1'b1;
			next_state = Init;
			compute_complete = 1'b1;
		end

		s8 : begin
			size_count_sel 	= 1'b0;
			R_Count_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			VSize_sel = 2'b10;
			V_RowCount_sel = 2'b00;
			V_CurrentRow_sel = 2'b00;
			Vread_addr_sel 	= 2'b11;
			Rread_addr_sel = 2'b11;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b00;
        	A_index_sel 	= 2'b00;
			B_index_sel 	= 2'b00;
        	Bread_addr_sel 		= 2'b00;
        	Count_sel = 2'b10;
			Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b1;
        	Write_Address_sel = 2'b10;
			MatrixCount_sel = 2'b11;
			Calculate_V = 1'b0;
			compute_complete = 1'b0;
			if(S_Count==0)
				Calculate_S = 1'b0;
			else
				Calculate_S = 1'b1;
			
			next_state = s9;
			end

		s9 : begin
			size_count_sel 	= 1'b0;
			R_Count_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			VSize_sel = 2'b10;
			V_RowCount_sel = 2'b00;
			Vread_addr_sel 	= 2'b11;
			Rread_addr_sel = 2'b11;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b00;
        	A_index_sel 	= 2'b00;
			V_CurrentRow_sel = 2'b00;
        	Bread_addr_sel 		= 2'b00;
        	Count_sel = 2'b10;
			Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b0;
        	Write_Address_sel = 2'b01;
			MatrixCount_sel = 2'b11;
			Calculate_S = 1'b1;
			Calculate_V = 1'b0;
			compute_complete = 1'b0;
			next_state = s10;
			end

			s12 : begin
			size_count_sel 	= 1'b0;
			VSize_sel = 2'b10;
			Vread_addr_sel 	= 2'b00;
			Rread_addr_sel = 2'b00;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b00;
        	A_index_sel 	= 2'b00;
        	Bread_addr_sel 		= 2'b00;
        	Count_sel = 2'b00;
			Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b1;
			
        	Write_Address_sel = 2'b10;
			MatrixCount_sel = 2'b11;
			Calculate_S = 1'b1;
			Calculate_V = 1'b1;
			V_CurrentRow_sel = 2'b00;
			V_RowCount_sel = 2'b00;
			V_TotalCount_sel = 2'b0;
			R_Count_sel = 2'b00;
			compute_complete = 1'b0;
			next_state = s16;
			end

			s16 : begin
			size_count_sel 	= 1'b0;
			VSize_sel = 2'b10;
			Vread_addr_sel 	= 2'b00;
			Rread_addr_sel = 2'b00;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b00;
        	A_index_sel 	= 2'b00;
        	Bread_addr_sel 		= 2'b00;
        	Count_sel = 2'b00;
			Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b0;
			
        	Write_Address_sel = 2'b10;
			MatrixCount_sel = 2'b11;
			Calculate_S = 1'b1;
			Calculate_V = 1'b1;
			V_CurrentRow_sel = 2'b00;
			V_RowCount_sel = 2'b00;
			V_TotalCount_sel = 2'b0;
			R_Count_sel = 2'b01;
			compute_complete = 1'b0;
			next_state = s15;
			end

			s15 : begin
				
				V_TotalCount_sel    = 2'b10;
				size_count_sel      = 1'b0;
				VSize_sel           = 2'b10;
				Rread_addr_sel      = 2'b01;
				Vread_addr_sel      = 2'b01;
				size_count_sel2     = 2'b00;
				Aread_addr_sel      = 2'b00;
				A_index_sel         = 2'b00;
				Bread_addr_sel      = 2'b00;
				Count_sel           = 2'b00;
				Accumulate_sel      = 1'b0;
				Write_enable        = 1'b0;
				Write_Address_sel   = 2'b10;
				MatrixCount_sel     = 2'b11;
				Calculate_S         = 1'b1;
				Calculate_V         = 1'b1;
				R_Count_sel         = 2'b01;
				compute_complete    = 1'b0;
				next_state          = s14;

				if ((V_CurrentRow + 1'b1) % VSize[15:0] == 1'b0)
					Vread_addr_sel = 2'b00;

				if (V_RowCount == ASize[31:16]) begin
					V_RowCount_sel = 2'b00;
					Vread_addr_sel = 2'b00;
				end else begin
					V_RowCount_sel = 2'b01;
				end

				V_CurrentRow_sel = (V_RowCount == ASize[31:16] - 1) ? 2'b01 : 2'b10;
				if ((V_CurrentRow + 1'b1) % VSize[15:0] == 1'b0)
					V_CurrentRow_sel = 2'b00;

				if (ASize[31:16] == 1'b1 || ASize[15:0] == 1'b1) begin
					V_CurrentRow_sel = 2'b00;
					next_state       = s18;
					Rread_addr_sel   = 2'b10;
				end
			end

			
			s13 : begin
			V_TotalCount_sel = 2'b10;
			V_RowCount_sel = 2'b00;

			if(((V_CurrentRow+1'b1) % VSize[15:0]) ==1'b0)
			begin
			Vread_addr_sel 	= 2'b00;
			end

			size_count_sel 	= 1'b0;
			VSize_sel = 2'b10;
			Rread_addr_sel = 2'b01;
			Vread_addr_sel 	= 2'b01;
        	size_count_sel2 = 2'b00;
			if(V_RowCount == ASize[31:16])
			begin
			Vread_addr_sel 	= 2'b00;
			end
			else
			V_RowCount_sel = 2'b01;
			Aread_addr_sel 	= 2'b00;
        	A_index_sel 	= 2'b00;
        	Bread_addr_sel 		= 2'b00;
        	Count_sel = 2'b00;
			Accumulate_sel 	= 1'b1;
        	Write_enable 	= 1'b0;
        	Write_Address_sel = 2'b10;
			MatrixCount_sel = 2'b11;
			Calculate_S = 1'b1;
			Calculate_V = 1'b1;
			R_Count_sel = 2'b01;
			compute_complete = 1'b0;

			if(V_RowCount == ASize[31:16]-1)
			V_CurrentRow_sel = 2'b01;
			else
			V_CurrentRow_sel = 2'b10;
			if(V_RowCount == 1'b1)
			begin
			Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b1;
			end
			if(((R_Count+1) % (VSize[15:0]*VSize[31:16])) ==1'b0)
			begin
			V_TotalCount_sel = 2'b01;
			V_CurrentRow_sel = 2'b00;
			end
			if((V_CurrentRow+1'b1) % (VSize[15:0]) ==1'b0)
			begin
			V_CurrentRow_sel = 2'b00;
			end
			next_state = s14;
			end  


			s14 : begin
    
				V_TotalCount_sel    = 2'b10;
				size_count_sel      = 1'b0;
				VSize_sel           = 2'b10;
				Rread_addr_sel      = 2'b01;
				Vread_addr_sel      = 2'b01;
				size_count_sel2     = 2'b00;
				Aread_addr_sel      = 2'b00;
				A_index_sel         = 2'b00;
				Bread_addr_sel      = 2'b00;
				Count_sel           = 2'b10;
				Accumulate_sel      = 1'b1;
				Write_enable        = 1'b0;
				Write_Address_sel   = 2'b01;
				MatrixCount_sel     = 2'b11;
				Calculate_S         = 1'b1;
				Calculate_V         = 1'b1;
				R_Count_sel         = 2'b01;
				compute_complete    = 1'b0;
				next_state          = s13;

				if (V_RowCount == ASize[31:16]) begin
					V_RowCount_sel  = 2'b00;
					Vread_addr_sel  = 2'b00;
					Rread_addr_sel  = 2'b00;
				end else begin
					V_RowCount_sel = 2'b01;
				end
				if (V_RowCount == ASize[31:16] - 1) begin
					V_CurrentRow_sel = 2'b01;
				end else begin
					V_CurrentRow_sel = 2'b10;
				end

				if ((R_Count + 1) % (VSize[15:0] * VSize[31:16]) == 1'b0) begin
					V_TotalCount_sel = 2'b01;
				end

				if ((V_CurrentRow + 1'b1) % VSize[15:0] == 1'b0) begin
					Vread_addr_sel = 2'b00;
				end

				if (V_RowCount != VSize[31:16]) begin
					Write_Address_sel = 2'b10;
				end

				if (V_TotalCount == VSize[31:16]) begin
					next_state = s7;
				end
			end


		s18 : begin
			//This state and s17 is to handle any 1x or x1 matrices
			size_count_sel 	= 1'b0;
			VSize_sel = 2'b10;
			Vread_addr_sel 	= 2'b01;
			Rread_addr_sel = 2'b10;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b00;
        	A_index_sel 	= 2'b00;
        	Bread_addr_sel 		= 2'b00;
        	Count_sel = 2'b00;
			Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b0;
			
        	Write_Address_sel = 2'b01;
			MatrixCount_sel = 2'b11;
			Calculate_S = 1'b1;
			Calculate_V = 1'b1;
			V_CurrentRow_sel = 2'b01;
			V_RowCount_sel = 2'b00;
			V_TotalCount_sel = 2'b0;
			R_Count_sel = 2'b00;
			compute_complete = 1'b0;
			if(V_CurrentRow == VSize[15:0]-1'b1)
			next_state = s7;
			else
			next_state = s17;

		end	

		s17 : begin
			size_count_sel 	= 1'b0;
			VSize_sel = 2'b10;
			Vread_addr_sel 	= 2'b01;
			Rread_addr_sel = 2'b10;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b00;
        	A_index_sel 	= 2'b00;
        	Bread_addr_sel 		= 2'b00;
        	Count_sel = 2'b00;
			Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b1;
			
        	Write_Address_sel = 2'b01;
			MatrixCount_sel = 2'b11;
			Calculate_S = 1'b1;
			Calculate_V = 1'b1;
			V_CurrentRow_sel = 2'b01;
			V_RowCount_sel = 2'b00;
			V_TotalCount_sel = 2'b0;
			R_Count_sel = 2'b00;
			compute_complete = 1'b0;
			if(V_CurrentRow == VSize[15:0])
			next_state = s7;
			else
			next_state = s17;

		end	

			
		default : begin
			//This is the default case
			size_count_sel 	= 1'b0;
			VSize_sel = 2'b00;
			V_TotalCount_sel = 2'b00;
			Vread_addr_sel = 2'b11;
			Rread_addr_sel = 2'b11;
        	size_count_sel2 = 2'b00;
			Aread_addr_sel 	= 2'b10;
        	A_index_sel 	= 2'b00;
        	Bread_addr_sel 		= 2'b11;
			V_CurrentRow_sel = 2'b00;
        	Count_sel = 2'b00;
			V_RowCount_sel = 2'b00;
			Accumulate_sel 	= 1'b0;
        	Write_enable 	= 1'b0;
        	Write_Address_sel = 2'b10;
			MatrixCount_sel = 2'b11;
			R_Count_sel = 2'b00;
			Calculate_S = 1'b1;
			Calculate_V = 1'b1;
			next_state 	= Init;
			compute_complete = 1'b0;
		end
		endcase 
	end


	//Accumulator register
	always @(posedge clk) begin
			if (Accumulate_sel == 1'b0)
				Accumulator <= 32'b0;
			else if (Accumulate_sel == 1'b1)
				Accumulator <= mac_result_z;
	end

	//Read address register
	always @(posedge clk) begin
			if (Aread_addr_sel == 2'b00)
			begin
				if (Count - (Count / ASize[31:16]) * ASize[31:16] != 0) 
       			 	A_addr <= ((Count - (Count / ASize[31:16]) * ASize[31:16])) * ASize[15:0] + 32'b1;
				else
					A_addr <= 32'b1;
			end
			else if (Aread_addr_sel == 2'b01) 
				A_addr <= A_addr + 32'b1;
			else if (Aread_addr_sel == 2'b10)
				A_addr <= A_addr;
			else if(Aread_addr_sel == 2'b11)
				A_addr <= 32'b0;
	end
  
  //Read weight address register
  always @(posedge clk) begin
			if (Bread_addr_sel == 2'b00)
			begin
				B_addr <= 32'b1 + ((BSize[31:16]*BSize[15:0])*CountMatrix);
				if (Count>=ASize[31:16]*3)
					B_addr <= (BSize[31:16]*BSize[15:0]);
			end
			else if (Bread_addr_sel == 2'b01)
				B_addr <= B_addr + 32'b1;
			else if (Bread_addr_sel == 2'b10)
				B_addr <= B_addr;
			else if(Bread_addr_sel == 2'b11)
				B_addr <= 32'b0;
	end

	//Read address register
	always @(posedge clk) begin
			if (Vread_addr_sel == 2'b00)
			begin
				V_addr <= ((VSize[31:16]*VSize[15:0])*2)+V_CurrentRow+16'b1;
			end
			else if (Vread_addr_sel == 2'b01) 
			begin
				if (ASize[31:16] == 1'b1 || ASize[15:0]==1'b1)
				V_addr <= V_addr + 1'b1;
				else
				V_addr <= V_addr + VSize[15:0];
			end
			else if (Vread_addr_sel == 2'b10)
				V_addr <= V_addr;
			else if(Vread_addr_sel == 2'b11)
				V_addr <= 32'b0;
	end

	//Read address register
		always @(posedge clk) begin
			if (Rread_addr_sel == 2'b00)
			begin
				R_addr <= (((VSize[31:16]*VSize[15:0])*3))+(VSize[31:16]*V_TotalCount);

			end
			else if (Rread_addr_sel == 2'b01) 
				R_addr <= R_addr + 1'b1;
			else if (Rread_addr_sel == 2'b10)
				R_addr <= R_addr;
			else if(Rread_addr_sel == 2'b11)
				R_addr <= 32'b0;
	end

	always @(posedge clk) begin
			if (V_TotalCount_sel == 2'b00)
				V_TotalCount <= 16'b0;
			else if (V_TotalCount_sel == 2'b01)
				V_TotalCount <= V_TotalCount + 16'b1;
			else if (V_TotalCount_sel == 2'b10)
				V_TotalCount <= V_TotalCount;
				end

	always @(posedge clk) begin
			if (R_Count_sel == 2'b0)
				R_Count <= 16'b0;
			else if (R_Count_sel == 2'b01)
				R_Count <= R_Count + 16'b1;
			else if (R_Count_sel == 2'b10)
				R_Count <= R_Count;
				end

	 always @(posedge clk) begin
			if (V_RowCount_sel == 2'b00)
				V_RowCount <= 16'b1;
			else if (V_RowCount_sel == 2'b01)
				V_RowCount <= V_RowCount + 16'b1;
			else if (V_RowCount_sel == 2'b10)
				V_RowCount <= V_RowCount;
			else if (V_RowCount_sel == 2'b11)
				V_RowCount <= 2'b0;
	end

	always @(posedge clk) begin
			if (V_CurrentRow_sel == 2'b0)
				V_CurrentRow <= 16'b0;
			else if (V_CurrentRow_sel == 2'b01)
				V_CurrentRow <= V_CurrentRow + 16'b1;
			else if (V_CurrentRow_sel == 2'b10)
				V_CurrentRow <= V_CurrentRow;
	end

	always @(posedge clk) begin
			if (VSize_sel == 2'b0)
				VSize <= 16'b1;
			else if (VSize_sel == 2'b01)
				VSize <= ASize;
			else if (VSize_sel == 2'b10)
				VSize <= VSize;
	end

  always @(posedge clk) begin
			if (Write_Address_sel == 2'b0)
				Write_addr <= 32'b0;
			else if (Write_Address_sel == 2'b01)
				Write_addr <= Write_addr + 32'b1;
			else if (Write_Address_sel == 2'b10)
				Write_addr <= Write_addr;
	end

  always @(posedge clk) begin
			if (Count_sel == 2'b0)
				Count <= 16'b0;
			else if (Count_sel == 2'b01)
				Count <= Count + 16'b1;
			else if (Count_sel == 2'b10)
				Count <= Count;
	end

	  always @(posedge clk) begin
			if (MatrixCount_sel == 2'b00)
				CountMatrix <= 16'b0;
			else if (MatrixCount_sel == 2'b01)
				CountMatrix <= CountMatrix + 16'b1;
			else if (MatrixCount_sel == 2'b11)
				CountMatrix <= CountMatrix;
	end

  always @(posedge clk) begin
			if (A_index_sel == 2'b00)
				Aindex <= 16'b1;
			else if (A_index_sel == 2'b01)
				Aindex <= Aindex + 16'b1;
			else if (A_index_sel == 2'b11)
				Aindex <= 16'b0;
			
	end

	 always @(posedge clk) begin
			if (B_index_sel == 2'b00)
				Bindex <= 16'b1;
			else if (B_index_sel == 2'b01)
				Bindex <= Bindex + 16'b1;
			else if (B_index_sel == 2'b11)
				Bindex <= 16'b0;
			
	end

  always @(posedge clk) begin
		if (size_count_sel2 == 2'b01)
			begin
			ASize  <= tb__dut__sram_input_read_data;
			BSize  <= tb__dut__sram_weight_read_data;
			end
		else if(size_count_sel2 == 2'b00)
			begin
			ASize  <= ASize;
			BSize  <= BSize;
			end
		else if(size_count_sel2 == 2'b11)
			begin
			ASize  <= {ASize[31:16], BSize[15:0]};
			BSize  <= {BSize[15:0], ASize[31:16]};
			end
		else if(size_count_sel2 == 2'b10)
			begin
			ASize  <= ASize;
			BSize  <= BSize;
			end
		
			
	end
	
endmodule