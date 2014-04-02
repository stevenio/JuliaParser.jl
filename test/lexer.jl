const Lexer = JuliaParser.Lexer

facts("test skip to end of line") do
    io = IOBuffer("abcd\nabcd\n")
    Lexer.skip_to_eol(io)
    @fact position(io) => 5
    skip(io, 2)
    @fact position(io) => 7
    Lexer.skip_to_eol(io)
    @fact position(io) => 10 
    @fact eof(io) => true

    context("no line break in buffer") do 
        io = IOBuffer("abcde")
        Lexer.skip_to_eol(io)
        @fact position(io) => 5
        @fact eof(io) => true
    end

    context("empty buffer") do
        io = IOBuffer()
        Lexer.skip_to_eol(io)
        @fact eof(io) => true
    end
end


facts("test read operator") do
    for op in Lexer.operators
        str = " $(string(op)) "
        io = IOBuffer(str)
        _ = Lexer.readchar(io)
        c = Lexer.readchar(io)
        res = Lexer.read_operator(io, c)
        @fact res => op
    end
end


facts("test string_to_number") do
   
    @fact_throws Lexer.string_to_number("")
    @fact_throws Lexer.string_to_number("1x10")
    @fact_throws Lexer.string_to_number("x10")
    @fact_throws Lexer.string_to_number("1.f.10")
    @fact_throws Lexer.string_to_number("b10")
    @fact_throws Lexer.string_to_number("0xzz")
    @fact_throws Lexer.string_to_number("0b22")
    
    context("NaN") do
        for s in ("NaN", "+NaN", "-NaN")
            n = Lexer.string_to_number(s)
            @fact isnan(n) => true
            @fact isnan(n) => isnan(eval(parse(s)))
        end
    end

    context("Inf") do
        for s in ("Inf", "+Inf", "-Inf")
            n = Lexer.string_to_number(s)
            @fact isinf(n) => true
            @fact isinf(n) => isinf(eval(parse(s)))
        end
    end

    context("float64") do
        s = "1.0"
        n = Lexer.string_to_number(s)
        @fact n => 1.0
        @fact n => parse(s)
        @fact typeof(n) => Float64
        @fact typeof(n) => typeof(parse(s))

        s = "-1.0"
        n = Lexer.string_to_number(s)
        @fact n => -1.0
        @fact n => parse(s)
        @fact typeof(n) => Float64
        @fact typeof(n) => typeof(parse(s))

        s = "1."
        n = Lexer.string_to_number(s)
        @fact n => 1.0
        @fact n => parse(s)
        @fact typeof(n) => Float64
        @fact typeof(n) => typeof(parse(s))

        s = "1e10"
        n = Lexer.string_to_number(s)
        @fact n => 1.0e10
        @fact n => parse(s)
        @fact typeof(n) => Float64
        @fact typeof(n) => typeof(parse(s))
        
        s = "-1E10"
        n = Lexer.string_to_number(s)
        @fact n => -1.0e10
        @fact n => parse(s)
        @fact typeof(n) => Float64
        @fact typeof(n) => typeof(parse(s))

        s = "0x1p0"
        n = Lexer.string_to_number(s)
        @fact n => 1.0
        @fact n => parse(s)
        @fact typeof(n) => Float64
        @fact typeof(n) => typeof(parse(s))

        s = "0x1.8p3"
        n = Lexer.string_to_number(s)
        @fact n => 12.0
        @fact n => parse(s)
        @fact typeof(n) => Float64
        @fact typeof(n) => typeof(parse(s))

        s = "0x0.4p-1"
        n = Lexer.string_to_number(s)
        @fact n => 0.125
        @fact n => parse(s)
        @fact typeof(n) => Float64
        @fact typeof(n) => typeof(parse(s))

        for _ = 1:10
            tn = rand()
            s  = string(tn)
            n  = Lexer.string_to_number(s)
            @fact n => tn
            @fact typeof(n) => Float64
            @fact n => parse(s)
            @fact typeof(n) => typeof(parse(s))
        end
    end

    context("float32") do 
        s = "1.0f0"
        n = Lexer.string_to_number(s)
        @fact n => 1.0
        @fact typeof(n) => Float32
        @fact n => parse(s)
        @fact typeof(n) => typeof(parse(s))

        s = "-1.f0"
        n = Lexer.string_to_number(s)
        @fact n => -1.0
        @fact typeof(n) => Float32
        @fact n => parse(s)
        @fact typeof(n) => typeof(parse(s))

        s = "1f0"
        n = Lexer.string_to_number(s)
        @fact n => 1.0
        @fact typeof(n) => Float32
        @fact n => parse(s)
        @fact typeof(n) => typeof(parse(s))

        s = "1f"
        @fact_throws Lexer.string_to_number(n)
        
        for _ = 1:10
            tn = rand(Float32)
            s  = repr(tn)
            n  = Lexer.string_to_number(s)
            @fact n => tn
            @fact typeof(n) => Float32
            @fact n => parse(s)
            @fact typeof(n) => typeof(parse(s))
        end
    end

    context("integers") do
        s = "1"
        n = Lexer.string_to_number(s)
        @fact n => 1
        @fact typeof(n) => Uint64

        s = "-1"
        n = Lexer.string_to_number(s)
        @fact n => -1
        @fact typeof(n) => Int64

        s = repr(typemin(Int64))
        n = Lexer.string_to_number(s)
        @fact n => typemin(Int64)
        @fact typeof(n) => Int64 

        s = repr(typemax(Int64))
        n = Lexer.string_to_number(s)
        @fact n => typemax(Int64)
        @fact typeof(n) => Uint64
        
        #=
        s = repr(typemax(Uint64))
        n = Lexer.string_to_number(s)
        @fact n => typemax(Uint64)
        @fact typeof(n) => Uint64
        =# 

        s = "0b010101"
        n = Lexer.string_to_number(s)
        @fact n => 21
        @fact typeof(n) => Uint64

        s = "-0b010101"
        n = Lexer.string_to_number(s)
        @fact n => -21
        @fact typeof(n) => Int64

        s = "0x15"
        n = Lexer.string_to_number(s)
        @fact n => 21
        @fact typeof(n) => Uint64

        s = "-0x15"
        n = Lexer.string_to_number(s)
        @fact n => -21
        @fact typeof(n) => Int64
    end
end


facts("test is char hex") do
    for i = 1:9
        @fact Lexer.is_char_hex(first("$i")) => true
    end
    for c in ['a', 'b', 'c', 'd', 'e', 'f']
        @fact Lexer.is_char_hex(c) => true
    end
    @fact Lexer.is_char_hex('z') => false
    for c in ['A', 'B', 'C', 'D', 'E', 'F']
        @fact Lexer.is_char_hex(c) => true
    end
    @fact Lexer.is_char_hex('Z') => false
end


facts("test is char oct") do
    for i = 1:9
        if i < 8
            @fact Lexer.is_char_oct(first("$i")) => true
        else
	    @fact Lexer.is_char_oct(first("$i")) => false
        end
    end
end


facts("test is char bin") do
    @fact Lexer.is_char_bin('0') => true
    @fact Lexer.is_char_bin('1') => true
    @fact Lexer.is_char_bin('2') => false
end


facts("test uint neg") do
    n = eval(Lexer.fix_uint_neg(true,  1))
    p = eval(Lexer.fix_uint_neg(false, 1))
    @fact n => -1 
    @fact p =>  1 
end


facts("test sized uint literal") do
    
    context("hexadecimal") do
        s  = "0x0"
        sn = int(s)
        n  = Lexer.sized_uint_literal(sn, s, 4)
        @fact sn => n
        @fact typeof(n) => Uint8
        
        for ty in (Uint8, Uint16, Uint32, Uint64, Uint128)
            @eval begin
                s = repr(typemax($ty))
                sn = uint128(s)
                n  = Lexer.sized_uint_literal(sn, s, 4)
                @fact sn => n
                @fact typeof(n) => $ty
                # parse / eval output (128 bit integers and BigInts
                # are returned as expressions
                pn = eval(parse(s))
                @fact pn => n
                @fact typeof(pn) => $ty
            end
        end
        
        s  = string(repr(typemax(Uint128)), "f")
        sn = BigInt(s) 
        n  = Lexer.sized_uint_literal(sn, s, 4)
        @fact sn == n => true
        @fact typeof(n) => BigInt

        pn = eval(parse(s))
        @fact pn == n => true
        @fact typeof(pn) => BigInt
    end
    
    context("octal") do
        s  = "0o0"
        sn = int(s)
        n  = Lexer.sized_uint_oct_literal(sn, s)
        @fact sn => n
        @fact typeof(n) => Uint8
        pn = parse(s)
        @fact pn == n => true
        @fact typeof(n) => typeof(pn)

        for ty in (Uint8, Uint16, Uint32, Uint64, Uint128)
            @eval begin
                s = string("0o", oct(typemax($ty)))
                sn = uint128(s)
                n  = Lexer.sized_uint_oct_literal(sn, s)
                @fact sn => n
                @fact typeof(n) => $ty
                        
                pn = eval(parse(s))
                @fact pn => n
                @fact typeof(pn) => $ty
            end
        end
        
        s  = string(repr(typemax(Uint128)), "7")
        sn = BigInt(s) 
        n  = Lexer.sized_uint_oct_literal(sn, s)
        @fact sn => n
        @fact typeof(n) => BigInt
        pn = eval(parse(s))
        @fact n => pn
        @fact typeof(n) => typeof(pn)
    end

    context("binary") do
        s  = "0b0"
        sn = int(s)
        n  = Lexer.sized_uint_literal(sn, s, 1)
        @fact sn => n
        @fact typeof(n) => Uint8
        
        for ty in (Uint8, Uint16, Uint32, Uint64, Uint128)
            @eval begin
                s = string("0b", bin(typemax($ty)))
                sn = uint128(s)
                n  = Lexer.sized_uint_literal(sn, s, 1)
                @fact sn => n
                @fact typeof(n) => $ty
            end
        end
        
        s  = string("0b", bin(typemax(Uint128)), "1")
        sn = BigInt(s) 
        n  = Lexer.sized_uint_literal(sn, s, 1)
        @fact sn => n
        @fact typeof(n) => BigInt
    end
end

facts("test accum_digits") do
    io = IOBuffer("1_000_000")
    c = Lexer.readchar(io)
    pred = Lexer.is_char_numeric
    digits, success = Lexer.accum_digits(io, pred, c, false)
    @fact digits => "1000000"
    @fact success => true
   
    io = IOBuffer("01_000_000")
    c = Lexer.peekchar(io)
    pred = Lexer.is_char_numeric
    digits, success = Lexer.accum_digits(io, pred, c, false)
    @fact digits => "01000000"
    @fact success => true


    io = IOBuffer("_000_000")
    c = Lexer.peekchar(io)
    pred = Lexer.is_char_numeric
    _, success = Lexer.accum_digits(io, pred, c, false)
    @fact success => false

    io = IOBuffer("_000_000")
    c = Lexer.peekchar(io)
    pred = Lexer.is_char_numeric
    _, success = Lexer.accum_digits(io, pred, c, true)
    @fact success => true
end


facts("test compare num strings") do
    a = "123"
    b = "1453"
    isless = Lexer.compare_num_strings(a, b) 
    @fact isless => true

    a = "123"
    b = "321"
    isless  = Lexer.compare_num_strings(a, b)
    @fact isless => true
    isless  = Lexer.compare_num_strings(b, a)
    @fact isless => false
end


facts("test skipwhitespace") do
    io = IOBuffer("   abc")
    Lexer.skipwhitespace(io)
    @fact position(io) => 4

    io = IOBuffer("abc")
    Lexer.skipwhitespace(io)
    @fact position(io) => 1

    io = IOBuffer(" \n abc")
    Lexer.skipwhitespace(io)
    @fact position(io) => 4

    io = IOBuffer("")
    Lexer.skipwhitespace(io)
    @fact position(io) => 0
end


facts("test skipcomment") do
    io = IOBuffer("#test\n")
    Lexer.skipcomment(io)
    @fact position(io) => 6

    io = IOBuffer("# \ntest")
    Lexer.skipcomment(io)
    @fact position(io) => 3

    io = IOBuffer("#")
    Lexer.skipcomment(io)
    @fact position(io) => 1 

    io = IOBuffer("# ")
    Lexer.skipcomment(io)
    @fact position(io) => 2 

    context("must start with a comment symbol") do
        io = IOBuffer("test")
        @fact_throws Lexer.skipcomment(io)
    end
end

facts("test skipcomment") do
    io = IOBuffer("#=test=#a")
    Lexer.skip_multiline_comment(io, 0)
    @fact position(io) => 8

    io = IOBuffer("#======#a")
    Lexer.skip_multiline_comment(io, 0)
    @fact position(io) => 8

    io = IOBuffer("#==#a")
    Lexer.skip_multiline_comment(io, 0)
    @fact position(io) => 4

    io = IOBuffer("#=test\ntest\n=#a")
    Lexer.skip_multiline_comment(io, 0)
    @fact position(io) => 14

    io = IOBuffer("#= # =#")
    Lexer.skip_multiline_comment(io, 0)
    @fact position(io) => 7

    io = IOBuffer("#=\n#= =# =#")
    Lexer.skip_multiline_comment(io, 0)
    @fact position(io) => 11

    io = IOBuffer("#= test")
    @fact_throws Lexer.skip_multiline_comment(io, 0)

    io = IOBuffer("#=#=#")
    @fact_throws Lexer.skip_multiline_comment(io, 0)
end