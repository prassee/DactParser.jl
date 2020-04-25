module DactParser

using DataFrames

#= 
A simple stata dct file parser. 

function - parseDctFile(filePath)

This function takes filePath as string. The parser ignores the first two line of the dct file 
and the remaining ones thus forms a array of ranges and name of the columns. =#
lineParseRegx = r"\s+_column\((?<colidx>\d+)\)\s+(?<coltyp>\w+)\s+(?<colnam>\w+)\s+\%(?<collen>\d+).+\s+"
function parseDctLine(line)
    a = parse(Int, match(lineParseRegx, line)[:colidx])
    b = parse(Int, match(lineParseRegx, line)[:collen])
    c = a:(a + b) - 1
    d = match(lineParseRegx, line)[:coltyp]
    typ = if d == "str12" 
        "String"
    elseif d == "byte" || d == "int"
        "Int"
    elseif d == "float" || d == "double"
        "Real"
    end
    [c, typ, match(lineParseRegx, line)[:colnam]]
end

function parseDctFile(filePath)::Array
    dctFile = readlines(filePath)
    allColLines =  dctFile[2:length(dctFile) - 1]
    cols = map(x->parseDctLine(x), allColLines)
    return cols
end

#= 
=#
function parseDatToDf(datFilePath, cols)
    datLines = readlines(datFilePath)
    colRange = map(col->col[1], cols)
    colNames = map(col->Base.replace(String(col[3]), " " => ""), cols)
    colTypes = map(col->col[2], cols)
    df = DataFrame()
    map(x->df[x] = [], 1:length(colNames))
    # populate matrix 
    for line in datLines
        row = map(col->String(line[col]), colRange)
        push!(df, row)
    end
    df
end
end # module
