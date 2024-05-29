// c 2023-12-29
// m 2023-12-30

void Main() {
    string zipFile = "test.zip";
    string zipFileOldPath = IO::FromDataFolder("Plugins/" + Meta::ExecutingPlugin().Name + "/" + zipFile);
    string zipFileCopied = "OpenplanetUnzipper/" + zipFile;
    string newFolder = IO::FromUserGameFolder("OpenplanetUnzipper/");

    print("zipFileOldPath: " + zipFileOldPath);

    if (!IO::FileExists(zipFileOldPath)) {
        print("\\F44test.zip missing");
        return;
    }

    string zipFileNewPath = IO::FromUserGameFolder(zipFileCopied);
    print("zipFileNewPath: " + zipFileNewPath);

    print("newFolder: " + newFolder);

    IO::File zipOld(zipFileOldPath, IO::FileMode::Read);
    MemoryBuffer@ buf = zipOld.Read(zipOld.Size());
    zipOld.Close();

    if (!IO::FolderExists(newFolder))
        IO::CreateFolder(newFolder);

    IO::File zipNew(zipFileNewPath, IO::FileMode::Write);
    zipNew.Write(buf);
    zipNew.Close();

    CSystemFidFile@ file = Fids::GetUser(zipFileCopied);
    if (file is null) {
        print("\\$F44null file");
        return;
    }

    string color = "\\$3FF ";

    // print("CSystemFidFile.Nod: " + tostring(tmp.Nod));
    print("CSystemFidFile.Text: "          + color + file.Text);
    print("CSystemFidFile.Compressed: "    + color + file.Compressed);
    print("CSystemFidFile.ByteSize: "      + color + file.ByteSize);
    print("CSystemFidFile.ByteSizeEd: "    + color + file.ByteSizeEd);
    print("CSystemFidFile.TimeWrite: "     + color + file.TimeWrite);
    print("CSystemFidFile.IsReadOnly: "    + color + file.IsReadOnly);
    print("CSystemFidFile.FileName: "      + color + file.FileName);
    print("CSystemFidFile.FullFileName: "  + color + file.FullFileName);
    print("CSystemFidFile.ShortFileName: " + color + file.ShortFileName);
    // print("CSystemFidFile.ParentFolder: " + tostring(tmp.ParentFolder));
    // print("CSystemFidFile.Container: " + tostring(tmp.Container));
    print("CSystemFidFile.IdName: "        + color + file.IdName);
    // print("CSystemFidFile.Id: " + tostring(tmp.Id));
    print("exists: "                       + color + file.OSCheckIfExists());

    CMwNod@ nod = Fids::Preload(file);
    if (nod is null) {
        print("\\$F44null nod");
        return;
    }

    CPlugFileZip@ zip = cast<CPlugFileZip@>(nod);
    if (zip is null) {
        print("\\$F44null zip");
        return;
    }

    ExploreNod(zip);

    print("CPlugFileZip.DisableCrc32Check: " + color + zip.DisableCrc32Check);
    // print("CPlugFileZip.Location: "          + color + zip.Location);
    print("CPlugFileZip.NbFolders: "         + color + zip.NbFolders);
    print("CPlugFileZip.NbFiles: "           + color + zip.NbFiles);
    print("CPlugFileZip.IdName: "            + color + zip.IdName);
    // print("CPlugFileZip.Id: "                + color + zip.Id);

    CSystemFidsFolder@ folder = zip.Location;
    if (folder is null) {
        print("\\$F44null folder");
    } else {
        // print("CSystemFidsFolder.Trees: "        + color + folder.Trees);
        // print("CSystemFidsFolder.Leaves: "       + color + folder.Leaves);
        print("CSystemFidsFolder.ByteSize: "     + color + folder.ByteSize);
        print("CSystemFidsFolder.ByteSizeEd: "   + color + folder.ByteSizeEd);
        print("CSystemFidsFolder.DirName: "      + color + folder.DirName);
        print("CSystemFidsFolder.FullDirName: "  + color + folder.FullDirName);
        // print("CSystemFidsFolder.ParentFolder: " + color + folder.ParentFolder);
        print("CSystemFidsFolder.IdName: "       + color + folder.IdName);
        // print("CSystemFidsFolder.Id: "           + color + folder.Id);
    }
}
