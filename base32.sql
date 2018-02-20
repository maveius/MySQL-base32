DROP FUNCTION IF EXISTS TO_BASE32;
CREATE FUNCTION TO_BASE32(to_encode TEXT)
RETURNS TEXT DETERMINISTIC
  BEGIN
    SET @alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567=';
    IF LENGTH(to_encode) = 0 THEN
      RETURN '';
    END IF;

    SET @binaryString := '';
    SET @idx = 1;

    binaryStringLoop: LOOP
      IF @idx > LENGTH(to_encode) THEN
        LEAVE binaryStringLoop;
      END IF;

      SET @char = SUBSTRING(to_encode,@idx,1);
      SET @binaryCharacter = LPAD(BIN(ORD(@char)),8,'0');

      SET @binaryString = CONCAT(@binaryString,@binaryCharacter);

      SET @idx = @idx + 1;
      ITERATE binaryStringLoop;
    END LOOP;


    IF SUBSTRING(@binaryString, -1, 1) = ' ' THEN
      SET @binaryString = SUBSTRING(@binaryString, 1, LENGTH(@binaryString)-1);
    END IF;

    SET @idx = 1;
    SET @offset = 5;
    SET @base32String = '';
    SET @numberOfChunks = 0;
    SET @bitSize = 8;
    SET @baseBinary = 2;
    SET @baseDeciamal = 10;
    SET @binaryStringFiveBits = '';

    divideToFiveBitsLoop: LOOP
      IF @idx > LENGTH(@binaryString) THEN
        LEAVE divideToFiveBitsLoop;
      END IF;

      SET @fiveBits = RPAD(SUBSTRING(@binaryString, @idx, @offset), @offset, 0);
      SET @binaryStringFiveBits = CONCAT(@binaryStringFiveBits, ' ', @fiveBits);
      SET @base32CharacterIndex = CONV(
          @fiveBits,
          @baseBinary,
          @baseDeciamal
      );
      SET @base32Character = SUBSTRING(@alphabet, (@base32CharacterIndex+1), 1);

      IF @idx < LENGTH(@binaryString) THEN
        SET @base32String = CONCAT(@base32String, @base32Character);
      END IF;

      SET @idx = @idx + @offset;
      SET @numberOfChunks = @numberOfChunks + 1;

      ITERATE divideToFiveBitsLoop;
    END LOOP;

    SET @charactersToAppend = 0;
    SET @characterIndex = 32;
    IF MOD(@numberOfChunks, @bitSize) != 0 THEN
      SET @charactersToAppend = @bitSize - MOD(@numberOfChunks, @bitSize);
    END IF;


    SET @idx = 1;
    base32complementLoop: LOOP
      IF @idx > @charactersToAppend THEN
        LEAVE base32complementLoop;
      END IF;

      SET @char = SUBSTRING(@alphabet,33,1);

      SET @base32String = CONCAT(@base32String, @char);

      SET @idx = @idx + 1;
      ITERATE base32complementLoop;
    END LOOP;

    RETURN @base32String;
  END;

# Use
# SELECT TO_BASE32('MDQxZmE1ZmM2Y2Y1MzVjasd');
