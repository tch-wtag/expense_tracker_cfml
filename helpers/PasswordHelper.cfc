component displayname="PasswordHelper" {

    public string function hashPassword(required string password, numeric iterations=310000) {
        return generatePBKDF2Hash(arguments.password, arguments.iterations);
    }

    public boolean function verifyPassword(required string password, required string hash) {
        try {
            return verifyPBKDF2Hash(arguments.password, arguments.hash);
        } catch (any e) {
            writeLog(file="security", text="Password verification error: " & e.message);
            return false;
        }
    }

    private string function generatePBKDF2Hash(required string password, numeric iterations=310000) {
        var salt = generateSecretKey("AES", 256);
        var saltBase64 = toBase64(salt);
        var keyLength = 512;

        var SecretKeyFactory = createObject("java", "javax.crypto.SecretKeyFactory");
        var PBEKeySpec = createObject("java", "javax.crypto.spec.PBEKeySpec");

        var spec = PBEKeySpec.init(
            javaCast("char[]", arguments.password.toCharArray()),
            toBinary(saltBase64),
            javaCast("int", arguments.iterations),
            javaCast("int", keyLength)
        );

        var skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA512");
        var hash = skf.generateSecret(spec).getEncoded();
        var hashBase64 = toBase64(hash);

        return "pbkdf2_sha512$" & arguments.iterations & "$" & saltBase64 & "$" & hashBase64;
    }

    private boolean function verifyPBKDF2Hash(required string password, required string hash) {
        var parts = listToArray(arguments.hash, "$");
        if (arrayLen(parts) != 4) return false;

        var iterations = javaCast("int", parts[2]);
        var saltBase64 = parts[3];
        var originalHashBase64 = parts[4];

        var SecretKeyFactory = createObject("java", "javax.crypto.SecretKeyFactory");
        var PBEKeySpec = createObject("java", "javax.crypto.spec.PBEKeySpec");

        var spec = PBEKeySpec.init(
            javaCast("char[]", arguments.password.toCharArray()),
            toBinary(saltBase64),
            iterations,
            512
        );

        var skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA512");
        var testHash = skf.generateSecret(spec).getEncoded();
        var testHashBase64 = toBase64(testHash);

        return compareSecure(testHashBase64, originalHashBase64);
    }

    private boolean function compareSecure(required string a, required string b) {
        if (len(arguments.a) != len(arguments.b)) return false;
        var result = 0;
        for (var i = 1; i <= len(arguments.a); i++) {
            result = bitOr(result, bitXor(asc(mid(arguments.a, i, 1)), asc(mid(arguments.b, i, 1))));
        }
        return (result == 0);
    }
}
